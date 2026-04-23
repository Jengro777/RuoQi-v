module user

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreRoleTenantMember, CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update_user'; post]
pub fn (app &User) update_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_user_usecase(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	// Domain 层参数校验
	update_user_domain(req)!

	// Repository 层执行数据库更新
	return update_user_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_user_domain(req UpdateUserReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.username == '' {
		return error('username is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateUserReq {
	user_id     string    @[json: 'user_id']
	role_ids    []string  @[json: 'role_ids']
	avatar      string    @[json: 'avatar']
	description string    @[json: 'description']
	email       string    @[json: 'email']
	home_path   string    @[json: 'home_path']
	mobile      string    @[json: 'mobile']
	nickname    string    @[json: 'nickname']
	password    string    @[json: 'password']
	status      u8        @[default: 0; json: 'status']
	username    string    @[json: 'username']
	updated_at  time.Time @[json: 'updated_at']
}

pub struct UpdateUserResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_user_repo(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	// 更新用户基础信息
	sql db {
		dynamic update CoreUser set {
				avatar == req.avatar,
				email == req.email,
				phone == req.mobile,
				nickname == req.nickname,
				description == req.description,
				home_path == req.home_path,
				password == req.password,
				status == req.status,
				username == req.username,
				updated_at == req.updated_at
		} where id == req.user_id
	} or { return error('Failed to execute SQL query: ${err}') }

	// 更新用户角色
	mut user_roles := []CoreRoleTenantMember{cap: req.role_ids.len}
	for role_id in req.role_ids {
		user_roles << CoreRoleTenantMember{
			member_id: req.user_id
			role_id:   role_id
		}
	}
	// 先删除用户的所有角色
	sql db {
		delete from CoreRoleTenantMember where member_id == req.user_id
	} or { return error('Failed to delete user roles: ${err}') }

	// 再批量插入新角色
	for user_role in user_roles {
		sql db {
			insert user_role into CoreRoleTenantMember
		} or { return error('Failed to insert user roles: ${err}') }
	}

	return UpdateUserResp{
		msg: 'User updated successfully'
	}
}
