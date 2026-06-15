module token

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/delete_token'; post]
pub fn (app &Token) delete_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
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
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from IamToken where id == req.id
	}!
}
