module token

import time
import veb
import log
import json2 as json
import model { Context }
import model.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/delete_token'; post]
pub fn (app &Token) delete_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_token_usecase(mut ctx Context, req DeleteTokenReq) !map[string]string {
	delete_token_domain(req)!
	delete_token_repo(mut ctx, req)!
	return {
		'msg': 'Token deleted successfully'
	}
}

// ═══ Domain ═══
fn delete_token_domain(req DeleteTokenReq) ! {
	if req.id == '' {
		return error('token id is required')
	}
}

// ═══ DTO ═══
pub struct DeleteTokenReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn delete_token_repo(mut ctx Context, req DeleteTokenReq) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamToken set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id == req.id && del_flag == 0
	} or { return error('Failed to soft-delete token: ${err}') }
}
