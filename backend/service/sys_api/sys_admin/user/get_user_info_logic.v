module user

import veb
import log
import orm
// import x.json2 as json
import structs.schema_sys { SysUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/info'; get]
pub fn (app &User) user_info_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := get_user_info_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_user_info_usecase(mut ctx Context) !GetUserInfoResp {
	// 调用 Domain 层校验
	get_user_info_domain()!

	user_id := find_userid_by_token(mut ctx)!
	// 调用 Repository 层获取用户信息
	return get_user_info(mut ctx, user_id)!
}

// ----------------- Domain 层 -----------------
fn get_user_info_domain() ! {
	// if req.user_id == '' {
	// 	return error('user_id cannot be empty')
	// }
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct GetUserInfoReq {
	user_id ?string @[json: 'id']
}

pub struct GetUserInfoResp {
	user_id         string   @[json: 'user_id']
	username        string   @[json: 'username']
	nickname        string   @[json: 'nickname']
	avatar          string   @[json: 'avatar']
	desc            string   @[json: 'desc']
	home_path       string   @[json: 'homePath']
	department_info string   @[json: 'departmentName']
	role_names      []string @[json: 'roleName']
}

// ----------------- AdapterRepository 层 -----------------

fn get_user_info(mut ctx Context, user_id string) !GetUserInfoResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 查询用户基本信息
	mut q_user := orm.new_query[SysUser](db)
	users := q_user.select()!.where('id = ?', user_id)!.query()!
	if users.len == 0 {
		return error('User not found')
	}
	user := users[0]

	// 查询用户角色
	user_roles := sql db {
		select from schema_sys.SysUserRole where user_id == user_id
	}!
	mut user_role_ids := []string{}
	for role in user_roles {
		user_role_ids << role.role_id
	}

	mut user_role_names := []string{}
	if user_role_ids.len > 0 {
		roles := sql db {
			select from schema_sys.SysRole where id in user_role_ids
		}!
		for role in roles {
			user_role_names << role.name
		}
	}

	// 查询部门信息
	mut department_info := ''
	user_departments := sql db {
		select from schema_sys.SysUserDepartment where user_id == user_id
	}!
	if user_departments.len > 0 {
		department_id := user_departments[0].department_id
		departments := sql db {
			select from schema_sys.SysDepartment where id == department_id
		}!
		if departments.len > 0 {
			department_info = departments[0].name
		}
	}

	return GetUserInfoResp{
		user_id:         user.id
		username:        user.username
		nickname:        user.nickname
		avatar:          user.avatar or { '' }
		desc:            user.description or { '' }
		home_path:       user.home_path
		department_info: department_info
		role_names:      user_role_names
	}
}

fn find_userid_by_token(mut ctx Context) !string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 从标准 Header 中获取 Authorization: Bearer <token>
	auth_header := ctx.get_header(.authorization) or { '' }
	log.debug(auth_header)

	// 去掉前缀 "Bearer" 并去除多余空格，得到 token 内容
	req_token := auth_header.all_after('Bearer').trim_space()
	log.debug(req_token)

	// step1: 根据 token 查找 SysToken 表，验证 token 是否存在
	sys_token := sql db {
		select from schema_sys.SysToken where token == req_token limit 1
	}!
	if sys_token.len != 1 {
		return error('Token not found')
	}
	log.debug('user_id: ${sys_token[0].user_id}')

	user_id := sys_token[0].user_id

	return user_id
}
