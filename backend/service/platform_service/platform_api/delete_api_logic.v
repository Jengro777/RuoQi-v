module platform_api

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfApi }
import common.api as capi

// ═══ Handler ═══
@['/delete_api'; post]
pub fn (app &PlatformApi) delete_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteApiReq](ctx.req.data) or {
		return ctx.json(capi.json_error_400(err.msg()))
	}
	result := delete_api_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error_500(err.msg()))
	}
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_api_usecase(mut ctx Context, req DeleteApiReq) !DeleteApiResp {
	delete_api_domain(req)!
	return delete_api_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_api_domain(req DeleteApiReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct DeleteApiReq {
	id string @[json: 'id']
}

pub struct DeleteApiResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_api_repo(mut ctx Context, req DeleteApiReq) !DeleteApiResp {
	sr := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(sr.conn) or { log.warn('Failed to release conn: ${err}') } }
	sql sr.db {
		update PfApi set del_flag = 1 where id == req.id
	}!
	return DeleteApiResp{
		msg: 'API deleted'
	}
}
