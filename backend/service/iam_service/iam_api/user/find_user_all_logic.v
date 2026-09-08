module user

import veb
import log
import model { Context }
import model.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/find_user_all'; post]
pub fn (app &User) find_user_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_user_all_usecase(mut ctx) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_user_all_usecase(mut ctx Context) ![]IamUser {
	return find_user_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_user_all_repo(mut ctx Context) ![]IamUser {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	users := sql db {
		select from IamUser where del_flag == 0
	} or { return error('Failed: ${err}') }
	return users
}
