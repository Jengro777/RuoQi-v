module user

import veb
import log
import x.json2 as json
import structs.schema_core { CoreRole, CoreRoleTenantMember, CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/info'; get]
pub fn (app &User) user_info_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetUserInfoReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_user_info_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_user_info_usecase(mut ctx Context, req GetUserInfoReq) !GetUserInfoResp {
	// Domain 层参数校验
	get_user_info_domain(req)!

	// Repository 查询数据库
	return get_user_info_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_user_info_domain(req GetUserInfoReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetUserInfoReq {
	user_id string @[json: 'user_id']
}

pub struct GetUserInfoResp {
	user_id    string   @[json: 'user_id']
	username   string   @[json: 'username']
	nickname   string   @[json: 'nickname']
	avatar     string   @[json: 'avatar']
	desc       string   @[json: 'desc']
	home_path  string   @[json: 'home_path']
	role_names []string @[json: 'role_names']
}

// ----------------- Repository 层 -----------------
fn get_user_info_repo(mut ctx Context, req GetUserInfoReq) !GetUserInfoResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 查询用户
	users := sql db {
		select from CoreUser where id == req.user_id
	} or { return error('Failed to execute SQL query: ${err}') }

	if users.len == 0 {
		return error('User not found')
	}
	user := users[0]

	// 查询用户角色
	user_roles := sql db {
		select from CoreRoleTenantMember where member_id == req.user_id
	}!

	mut user_role_ids := []string{}
	for r in user_roles {
		user_role_ids << r.role_id
	}

	// 查询角色名称
	mut role_names := []string{}
	if user_role_ids.len > 0 {
		roles := sql db {
			select from CoreRole where id in user_role_ids
		}!
		for role in roles {
			role_names << role.name
		}
	}

	return GetUserInfoResp{
		user_id:    user.id
		username:   user.username
		nickname:   user.nickname
		avatar:     user.avatar or { '' }
		desc:       user.description or { '' }
		home_path:  user.home_path
		role_names: role_names
	}
}
