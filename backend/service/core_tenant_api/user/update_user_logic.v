module user

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_core { CoreRoleTenantMember, CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update_user'; post]
pub fn update_user_handler(app &User, mut ctx Context) veb.Result {
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
	mut sys_user := orm.new_query[CoreUser](db)

	sys_user.set('avatar = ?', req.avatar)!
		.set('email = ?', req.email)!
		.set('mobile = ?', req.mobile)!
		.set('nickname = ?', req.nickname)!
		.set('description = ?', req.description)!
		.set('home_path = ?', req.home_path)!
		.set('password = ?', req.password)!
		.set('status = ?', req.status)!
		.set('username = ?', req.username)!
		.set('updated_at = ?', req.updated_at)!
		.where('id = ?', req.user_id)!
		.update()!

	// 更新用户角色
	mut user_roles := []CoreRoleTenantMember{cap: req.role_ids.len}
	for role_id in req.role_ids {
		user_roles << CoreRoleTenantMember{
			member_id: req.user_id
			role_id:   role_id
		}
	}
	mut user_role := orm.new_query[CoreRoleTenantMember](db)

	user_role.delete()!.where('user_id = ?', req.user_id)!
		.insert_many(user_roles)!

	return UpdateUserResp{
		msg: 'User updated successfully'
	}
}
