module token

import time
import veb
import log
import model { Context }
import model.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/delete_token_by_user'; post]
pub fn (app &Token) delete_token_by_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := delete_token_by_user_usecase(mut ctx) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
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
		update IamToken set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where user_id == ctx.svc_iam.user_id && del_flag == 0
	} or { return error('Failed to soft-delete tokens: ${err}') }
}
