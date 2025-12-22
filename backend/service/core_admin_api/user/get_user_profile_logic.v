module user

import veb
import log
import orm
import x.json2 as json
import structs.schema_core { CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/profile'; get]
pub fn user_profile_handler(app &User, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UserProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := user_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn user_profile_usecase(mut ctx Context, req UserProfileReq) !UserProfileResp {
	// Domain 层参数校验
	user_profile_domain(req)!

	// Repository 查询数据
	return user_profile_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn user_profile_domain(req UserProfileReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UserProfileReq {
	user_id string @[json: 'user_id']
}

pub struct UserProfileResp {
	nickname string @[json: 'nickname']
	avatar   string @[json: 'avatar']
	email    string @[json: 'email']
}

// ----------------- Repository 层 -----------------
fn user_profile_repo(mut ctx Context, req UserProfileReq) !UserProfileResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut core_user := orm.new_query[CoreUser](db)
	result := core_user.select('id = ?', req.user_id)!.query()!

	if result.len == 0 {
		return error('User not found')
	}

	row := result[0]
	return UserProfileResp{
		nickname: row.nickname
		avatar:   row.avatar or { '' }
		email:    row.email or { '' }
	}
}
