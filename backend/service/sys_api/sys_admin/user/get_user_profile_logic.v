module user

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/profile'; get]
pub fn(app &User)user_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UserProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_user_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_user_profile_usecase(mut ctx Context, req UserProfileReq) !UserProfileResp {
	// 调用 Domain 层参数校验
	get_user_profile_domain(req)!

	// 调用 Repository 层获取用户信息
	return get_user_profile(mut ctx, req.user_id)!
}

// ----------------- Domain 层 -----------------
fn get_user_profile_domain(req UserProfileReq) ! {
	if req.user_id == '' {
		return error('user_id cannot be empty')
	}
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct UserProfileReq {
	user_id string @[json: 'user_id']
}

pub struct UserProfileResp {
	nickname string @[json: 'nickname']
	avatar   string @[json: 'avatar']
	mobile   string @[json: 'mobile']
	email    string @[json: 'email']
}

// ----------------- AdapterRepository 层 -----------------
fn get_user_profile(mut ctx Context, user_id string) !UserProfileResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	mut q_user := orm.new_query[SysUser](db)
	result := q_user.select()!.where('id = ?', user_id)!.query()!

	if result.len == 0 {
		return error('User not found')
	}

	row := result[0]

	return UserProfileResp{
		nickname: row.nickname
		avatar:   row.avatar or { '' }
		mobile:   row.mobile or { '' }
		email:    row.email or { '' }
	}
}
