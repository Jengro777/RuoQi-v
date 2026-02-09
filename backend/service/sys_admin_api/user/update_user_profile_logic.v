module user

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update_user_profile'; post]
pub fn (app &User) update_user_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateUserProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_user_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_user_profile_usecase(mut ctx Context, req UpdateUserProfileReq) !UpdateUserProfileResp {
	// Domain 层参数校验
	update_user_profile_domain(req)!

	// Repository 层更新用户资料
	return update_user_profile(mut ctx, req)!
}

// ----------------- Domain 层 -----------------
fn update_user_profile_domain(req UpdateUserProfileReq) ! {
	if req.user_id == '' {
		return error('user_id cannot be empty')
	}
	if req.nickname == '' {
		return error('nickname cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateUserProfileReq {
	user_id  string @[json: 'userId']
	avatar   string @[json: 'avatar']
	email    string @[json: 'email']
	mobile   string @[json: 'mobile']
	nickname string @[json: 'nickname']
}

pub struct UpdateUserProfileResp {
	msg string @[json: 'msg']
}

// ----------------- AdapterRepository 层 -----------------
fn update_user_profile(mut ctx Context, req UpdateUserProfileReq) !UpdateUserProfileResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	mut q_user := orm.new_query[SysUser](db)

	q_user.set('avatar = ?', req.avatar)!
		.set('email = ?', req.email)!
		.set('mobile = ?', req.mobile)!
		.set('nickname = ?', req.nickname)!
		.where('id = ?', req.user_id)!
		.update()!

	return UpdateUserProfileResp{
		msg: 'User profile updated successfully'
	}
}
