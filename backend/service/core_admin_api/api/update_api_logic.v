module api

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/update'; post]
pub fn (app &Api) update_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateCoreApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_api_usecase(mut ctx Context, req UpdateCoreApiReq) !UpdateCoreApiResp {
	// Domain 参数校验
	update_api_domain(req)!

	// Repository 执行更新
	return update_api_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_api_domain(req UpdateCoreApiReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateCoreApiReq {
	id           string     @[json: 'id'; required]
	path         ?string    @[json: 'path'; required]
	description  ?string    @[json: 'description']
	api_group    ?string    @[json: 'api_group'; required]
	service_name ?string    @[json: 'service_name'; required]
	method       ?string    @[json: 'method'; required]
	is_required  ?u8        @[default: 0; json: 'is_required'; required]
	source_type  ?string    @[json: 'source_type'; required]
	source_id    ?string    @[json: 'source_id'; required]
	updated_at   ?time.Time @[json: 'updated_at']
}

pub struct UpdateCoreApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_api_repo(mut ctx Context, req UpdateCoreApiReq) !UpdateCoreApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	up_expr := {
		if path := req.path { path == path },
		if description := req.description { description == description },
		if api_group := req.api_group { api_group == api_group },
		if service_name := req.service_name { service_name == service_name },
		if method := req.method { method == method },
		if is_required := req.is_required { is_required == is_required },
		if source_type := req.source_type { source_type == source_type },
		if source_id := req.source_id { source_id == source_id },
		updated_at == time.now()
	}

	sql db {
		dynamic update CoreApi set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateCoreApiResp{
		msg: 'API updated successfully'
	}
}
