module middleware

import veb
import structs { Context }
import structs.schema_sys
import common.jwt
import log

/* =============================================
JWT 权限认证中间件
=============================================
功能：
1. 从请求头中读取并验证 JWT Token
2. 验证 Token 是否在数据库中存在
3. 根据 Token 获取用户信息与角色
4. 校验该用户是否有访问当前 API 的权限
=============================================
*/
fn authority_jwt_verify(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 从自定义 Header 获取 secret（JWT 验证密钥）
	secret := ctx.get_custom_header('secret') or { '' }
	log.debug(secret)

	// 从标准 Header 中获取 Authorization: Bearer <token>
	auth_header := ctx.get_header(.authorization) or { '' }
	log.debug(auth_header)

	// 检查 Authorization 格式是否正确
	if auth_header.len == 0 || !auth_header.starts_with('Bearer ') {
		ctx.res.status_code = 401
		ctx.request_error('Missing or invalid authentication token')
		return false
	}

	// 去掉前缀 "Bearer" 并去除多余空格，得到 token 内容
	req_token := auth_header.all_after('Bearer').trim_space()
	log.debug(req_token)

	// 使用 common.jwt 模块验证 token 签名有效性
	verify := jwt.jwt_verify(secret, req_token)
	if verify == false {
		ctx.res.status_code = 401
		ctx.request_error('Authorization request error ')
		log.warn('Authorization error')
		return false
	}

	// >>>>> 权限验证阶段 >>>>>
	// 根据 token 获取用户所拥有的 API 路径列表
	user_api_list := get_userapilist_from_token(mut ctx, req_token) or { return false }

	// 如果不是超级管理员（'*' 表示拥有所有权限）
	// 则校验当前请求 URL 是否在授权的接口列表中
	if !user_api_list.contains('*') && ctx.req.url !in user_api_list {
		ctx.res.status_code = 403
		ctx.request_error("You don't have permission to perform this action")
		return false
	}
	// <<<<< 权限验证结束 <<<<<

	return true
}

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
fn get_userapilist_from_token(mut ctx Context, req_token string) ![]string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 检查数据库连接池
	if isnil(ctx.dbpool) {
		log.error('FATAL: ctx.dbpool is nil!')
		return error('Database pool not initialized')
	}

	log.debug('dbpool type: ${typeof(ctx.dbpool).name}')
	log.debug('Attempting to acquire connection...')

	// 从连接池中获取数据库连接
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		// 释放数据库连接回连接池
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	// step1: 根据 token 查找 SysToken 表，验证 token 是否存在
	sys_token := sql db {
		select from schema_sys.SysToken where token == req_token limit 1
	}!
	if sys_token.len != 1 {
		return error('Token not found')
	}
	log.debug('user_id: ${sys_token[0].user_id}')

	// 传递 user_id 到全局 Context
	ctx.user_id = sys_token[0].user_id
	dump(ctx.user_id)

	// step2: 根据 user_id 查询 SysUser 表，判断是否为超级管理员
	sys_user := sql db {
		select from schema_sys.SysUser where id == sys_token[0].user_id limit 1
	}!
	if sys_user.len != 1 {
		return error('User not found')
	}

	// 若用户为 root，则返回通配符 "*" 表示拥有所有权限
	if sys_user[0].is_root == 1 {
		log.debug('is_root: ${sys_user[0].is_root}, true')
		return ['*']
	}
	log.debug('is_root: ${sys_user[0].is_root}, false')

	// step3: 查询用户角色（一个用户可对应多个角色）
	sys_user_role := sql db {
		select from schema_sys.SysUserRole where user_id == sys_user[0].id
	}!
	if sys_user_role.len < 1 {
		return error('User role not found')
	}
	mut role_id_list := sys_user_role.map(it.role_id)
	log.debug('role_id: ${role_id_list}')

	// step4: 查询角色关联的 API
	sys_role_api := sql db {
		select from schema_sys.SysRoleApi where role_id in role_id_list
	}!
	if sys_role_api.len < 1 {
		return error('Role api not found')
	}
	mut api_id_list := sys_role_api.map(it.api_id)
	log.debug('api_id: ${api_id_list}')

	// step5: 查询 API 表，获取该角色可访问的接口路径
	// 注意：is_required == 1 的接口表示全局可访问（无需权限）
	sys_api := sql db {
		select from schema_sys.SysApi where id in api_id_list || is_required == 1
	}!
	if sys_api.len < 1 {
		return error('Api not found')
	}
	mut user_api_list := sys_api.map(it.path)
	log.debug('api_list: ${user_api_list}')

	return user_api_list
}

/* =============================================
初始化中间件配置
=============================================
在 veb 框架中，MiddlewareOptions 用于注册中间件
handler：中间件处理函数
after：是否在路由处理后执行（false 表示在请求前执行）
=============================================
*/
pub fn authority_middleware_sys() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: authority_jwt_verify // 指定认证函数
		after:   false                // 在请求处理前执行
	}
}
