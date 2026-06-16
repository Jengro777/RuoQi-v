module platform_api

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfApi }
import common.api as capi

// ═══ Handler ═══
@['/update_api'; post]
pub fn (app &PlatformApi) update_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateApiReq](ctx.req.data) or {
		return ctx.json(capi.json_error_400(err.msg()))
	}
	result := update_api_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error_500(err.msg()))
	}
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_api_usecase(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	update_api_domain(req)!
	return update_api_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_api_domain(req UpdateApiReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct UpdateApiReq {
	id           string  @[json: 'id']
	path         ?string @[json: 'path']
	description  ?string @[json: 'description']
	api_group    ?string @[json: 'apiGroup']
	service_name ?string @[json: 'serviceName']
	method       ?string @[json: 'method']
	is_required  ?u8     @[json: 'isRequired']
	status       ?u8     @[json: 'status']
}

pub struct UpdateApiResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_api_repo(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if path := req.path { path == path },
		if description := req.description { description == description },
		if api_group := req.api_group { api_group == api_group },
		if service_name := req.service_name { service_name == service_name },
		if method := req.method { method == method },
		if is_required := req.is_required { is_required == is_required },
		if status := req.status { status == status }
	}
	sql db {
		dynamic update PfApi set up_expr where id == req.id
	}!
	return UpdateApiResp{
		msg: 'API updated'
	}
}
