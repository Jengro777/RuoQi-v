module api

import veb
import log
import x.json2 as json
import structs.schema_core { CoreApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/delete'; post]
pub fn (app &Api) delete_api_handler(mut ctx Context) veb.Result {
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
	// Domain 校验
	delete_api_domain(req)!

	// Repository 执行删除
	return delete_api_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_api_domain(req DeleteApiReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteApiReq {
	id string @[json: 'id'; required]
}

pub struct DeleteApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_api_repo(mut ctx Context, req DeleteApiReq) !DeleteApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		delete from CoreApi where id == req.id
	} or { return error('Failed to delete API: ${err}') }

	return DeleteApiResp{
		msg: 'API deleted successfully'
	}
}
