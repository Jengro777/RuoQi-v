module token

import veb
import log
import structs { Context }
import structs.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/find_token_all'; post]
pub fn (app &Token) find_token_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_token_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_token_all_usecase(mut ctx Context) ![]IamToken {
	return find_token_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_token_all_repo(mut ctx Context) ![]IamToken {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	tokens := sql db {
		select from IamToken
	} or { return error('Failed: ${err}') }
	return tokens
}
