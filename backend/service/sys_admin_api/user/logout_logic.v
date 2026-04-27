module user

import veb
import log
import structs.schema_sys { SysToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/logout'; get; post]
pub fn (app &User) logout_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := logout_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn logout_usecase(mut ctx Context) !LogoutResp {
	// 调用 Domain 层校验参数
	logout_domain()!

	// 调用 Repository 层执行登出逻辑
	return logout(mut ctx, ctx.svc_sys.user_id)!
}

// ----------------- Domain 层 -----------------
fn logout_domain() ! {
	//
}

// ----------------- DTO 层 -----------------
pub struct LogoutReq {
	// user_id string @[json: 'user_id']
}

pub struct LogoutResp {
	msg string @[json: 'logout']
}

// ----------------- AdapterRepository 层 -----------------
fn logout(mut ctx Context, user_id string) !LogoutResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	sql db {
		update SysToken set status = 1 where id == user_id
	}!

	return LogoutResp{
		msg: 'Logout successful'
	}
}
