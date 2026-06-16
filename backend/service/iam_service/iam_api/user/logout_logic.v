module user

import veb
import log
import structs { Context }
import structs.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/logout'; get; post]
pub fn (app &User) logout_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := logout_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn logout_usecase(mut ctx Context) !LogoutResp {
	logout_repo(mut ctx)!
	return LogoutResp{
		msg: 'Logout successful'
	}
}

// ═══ DTO ═══
pub struct LogoutResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn logout_repo(mut ctx Context) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamToken set status = 1 where user_id == ctx.svc_iam.user_id
	}!
}
