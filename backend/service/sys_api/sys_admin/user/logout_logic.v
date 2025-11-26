module user

import veb
import log
import orm
import structs.schema_sys { SysToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/login_out'; post]
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
	return logout(mut ctx, ctx.svc_ctx.user_id)!
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
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	mut q_token := orm.new_query[SysToken](db)
	q_token.set('status = ?', '1')!.where('id = ?', user_id)!.update()!

	return LogoutResp{
		msg: 'Logout successful'
	}
}
