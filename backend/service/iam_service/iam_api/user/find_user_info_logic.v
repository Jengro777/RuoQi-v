module user

import veb
import log
import structs { Context }
import structs.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/find_user_info'; post]
pub fn (app &User) find_user_info_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_user_info_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_user_info_usecase(mut ctx Context) !IamUser {
	return find_user_info_repo(mut ctx)
}

// ═══ Repository ═══
fn find_user_info_repo(mut ctx Context) !IamUser {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	users := sql db {
		select from IamUser where id == ctx.svc_iam.user_id limit 1
	} or { return error('Failed: ${err}') }
	if users.len == 0 { return error('user not found') }
	return users[0]
}
