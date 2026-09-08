module platform_api

import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfApi }
import common.api as capi
import time

// ═══ Handler ═══
@['/update_api'; post]
pub fn (app &PlatformApi) update_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateApiReq](ctx.req.data) or {
		return ctx.json(capi.json_error(code: capi.err_common_param_invalid, msg: err.msg()))
	}
	result := update_api_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error(code: capi.err_common_server, msg: err.msg()))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_api_usecase(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	update_api_domain(req)!
	return update_api_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_api_domain(req UpdateApiReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateApiReq {
	id           string @[json: 'id']
	path         ?string @[json: 'path']
	description  ?string @[json: 'description']
	api_group    ?string @[json: 'apiGroup']
	service_name ?string @[json: 'serviceName']
	method       ?string @[json: 'method']
	is_required  ?u8 @[json: 'isRequired']
	status       ?u8 @[json: 'status']
}

pub struct UpdateApiResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_api_repo(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.path {
			path == v
		},
		if v := req.description {
			description == v
		},
		if v := req.api_group {
			api_group == v
		},
		if v := req.service_name {
			service_name == v
		},
		if v := req.method {
			method == v
		},
		if v := req.is_required {
			is_required == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update PfApi set up_expr where id == req.id
	}!
	return UpdateApiResp{
		msg: 'API updated'
	}
}
