module platform_api

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_platform { PfApi }
import common.api as capi

// ═══ Handler ═══
@['/find_api_by_id'; post]
pub fn (app &PlatformApi) find_api_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindApiByIdReq](ctx.req.data) or {
		return ctx.json(capi.json_error_400(err.msg()))
	}
	result := find_api_by_id_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error_500(err.msg()))
	}
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_api_by_id_usecase(mut ctx Context, req FindApiByIdReq) !PfApi {
	find_api_by_id_domain(req)!
	return find_api_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_api_by_id_domain(req FindApiByIdReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct FindApiByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_api_by_id_repo(mut ctx Context, req FindApiByIdReq) !PfApi {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	apis := sql db {
		select from PfApi where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed: ${err}') }
	if apis.len == 0 { return error('API not found') }
	return apis[0]
}
