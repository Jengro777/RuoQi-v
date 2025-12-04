module api

import veb
import log
import x.json2 as json
import structs.schema_sys { SysApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &Api) api_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_api_usecase(mut ctx Context, req DeleteApiReq) !DeleteApiResp {
	delete_api_domain(req)!
	return delete_api_by_ids(mut ctx, req.ids)
}

// ----------------- Domain 层 -----------------
fn delete_api_domain(req DeleteApiReq) ! {
	if req.ids == [] {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteApiReq {
	ids []string @[json: 'ids']
}

pub struct DeleteApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_api_by_ids(mut ctx Context, ids []string) !DeleteApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		delete from SysApi where id in ids
	} or { return error('Failed to delete API: ${err}') }

	return DeleteApiResp{
		msg: 'API deleted successfully'
	}
}
