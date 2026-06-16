module token

import veb
import log
import structs { Context }
import structs.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/delete_token_by_user'; post]
pub fn (app &Token) delete_token_by_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := delete_token_by_user_usecase(mut ctx) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_token_by_user_usecase(mut ctx Context) !map[string]string {
	delete_token_by_user_repo(mut ctx)!
	return {
		'msg': 'All tokens deleted successfully'
	}
}

// ═══ Repository ═══
fn delete_token_by_user_repo(mut ctx Context) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from IamToken where user_id == ctx.svc_iam.user_id
	}!
}
