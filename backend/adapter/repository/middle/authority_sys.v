module middle

import structs { Context }
import structs.schema_sys { SysApi, SysRoleApi, SysToken, SysUser, SysUserRole }
import db.mysql
import log

/* =============================================
根据 token 查询用户信息与权限
=============================================
1. 验证数据库连接池状态
2. 根据 token 查询 SysToken 表获取用户ID
3. 查询用户是否为 root 管理员（root 拥有所有权限）
4. 获取用户对应的角色 ID 列表
5. 获取角色对应的 API ID 列表
6. 查询 API 表，得到路径集合（path）
=============================================
*/

// 根据req_token获取用户API列表,完成用户Api鉴权
pub fn get_userapilist_from_token(mut ctx Context, req_token string) ![]string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 检查数据库连接池
	if isnil(ctx.dbpool) {
		log.error('FATAL: ctx.dbpool is nil!')
		ctx.res.status_code = 500
		ctx.request_error('Database not available')
		return error('Database pool not initialized')
	}

	log.debug('dbpool type: ${typeof(ctx.dbpool).name}')

	// 从连接池中获取数据库连接
	mut db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		// 释放数据库连接回连接池
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}
	log.debug('db_type: ${db}')

	// Step 1
	user_id := find_userid_by_token(mut ctx, db, req_token)!
	// Step 2:3
	role_id_list := find_roleids_by_userid(mut ctx, db, user_id)!
	// Step 4:5
	user_api_list := find_apiids_by_roleids(db, role_id_list)!

	return user_api_list
}

// 1: 根据token_jwt 获取用户ID
fn find_userid_by_token(mut ctx Context, db mysql.DB, req_token string) !string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// step1: 根据 token 查找 SysToken 表，验证 token 是否存在
	sys_token := sql db {
		select from SysToken where token == req_token limit 1
	} or { return error('sys_token sql error ${req_token}') }
	log.debug('sys_token: ${sys_token}')

	if sys_token.len != 1 {
		return error('Token not found ')
	}
	log.debug('user_id: ${sys_token[0].user_id}')

	// 传递 user_id 到全局 Context
	ctx.svc_sys.user_id = sys_token[0].user_id

	return sys_token[0].user_id
}

// 2:3: 根据user_id 获取用户角色ID列表
fn find_roleids_by_userid(mut ctx Context, db mysql.DB, user_id string) ![]string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// step2: 根据 user_id 查询 SysUser 表，判断是否为超级管理员
	sys_user := sql db {
		select from SysUser where id == user_id limit 1
	} or { return error('sys_user sql error') }
	if sys_user.len != 1 {
		return error('User not found')
	}

	// 若用户为 root，则返回通配符 "*" 表示拥有所有权限
	if sys_user[0].is_root == 1 {
		log.debug('is_root: ${sys_user[0].is_root}, true')
		ctx.svc_sys.role_ids = ['*'] // 传递 role_ids 到全局 Context, 可以减少后续业务用户角色列表的数据库查询
		return ['*']
	}
	log.debug('is_root: ${sys_user[0].is_root}, false')

	// step3: 查询用户角色（一个用户可对应多个角色）
	sys_user_role := sql db {
		select from SysUserRole where user_id == sys_user[0].id
	} or { return error('sys_user_role sql error') }
	if sys_user_role.len < 1 {
		return error('User role not found')
	}

	mut role_id_list := sys_user_role.map(it.role_id)
	log.debug('role_id: ${role_id_list}')

	ctx.svc_sys.role_ids = role_id_list // 传递 role_ids 到全局 Context, 可以减少后续业务用户角色列表的数据库查询

	return role_id_list
}

// 4:5: 查询角色关联的 API ID
fn find_apiids_by_roleids(db mysql.DB, role_id_list []string) ![]string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut sys_api := []SysApi{}
	if role_id_list == ['*'] {
		sys_api = sql db {
			select from SysApi
		} or { return error('sys_api sql error') }
		if sys_api.len < 1 {
			return error('Api not found')
		}
	} else {
		// step4: 查询角色关联的 API ID
		sys_role_api := sql db {
			select from SysRoleApi where role_id in role_id_list
		} or { return error('sys_role_api sql error') }
		if sys_role_api.len < 1 {
			return error('Role api not found')
		}

		mut api_id_list := sys_role_api.map(it.api_id)
		log.debug('api_id: ${api_id_list}')

		// step5: 查询 API 表，获取该角色可访问的接口路径
		// 注意：is_required == 1 的接口表示全局可访问（无需权限）
		sys_api = sql db {
			select from SysApi where id in api_id_list || is_required == 1
		} or { return error('sys_api sql error') }
		if sys_api.len < 1 {
			return error('Api not found')
		}
	}

	mut user_api_list := sys_api.map(it.path)

	return user_api_list
}
