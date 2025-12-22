module user

import veb
import log
import orm
import x.json2 as json
import structs.schema_core { CoreToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/login_out'; post]
pub fn logout_handler(app &User, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[LogoutReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := logout_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn logout_usecase(mut ctx Context, req LogoutReq) !LogoutResp {
	// Domain 校验
	logout_domain(req)!

	// Repository 执行更新
	return logout_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn logout_domain(req LogoutReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct LogoutReq {
	user_id string @[json: 'user_id']
}

pub struct LogoutResp {
	logout string @[json: 'logout']
}

// ----------------- Repository 层 -----------------
fn logout_repo(mut ctx Context, req LogoutReq) !LogoutResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[CoreToken](db)
	q.set('status = ?', '1')!.where('id = ?', req.user_id)!.update()!

	return LogoutResp{
		logout: 'Logout successful'
	}
}
