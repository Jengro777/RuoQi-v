module platform_configuration

import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfConfig }
import common.api
import time

// ═══ Handler ═══
@['/update_config'; post]
pub fn (app &PlatformConfiguration) update_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateConfigReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_config_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_config_usecase(mut ctx Context, req UpdateConfigReq) !UpdateConfigResp {
	update_config_domain(req)!
	return update_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_config_domain(req UpdateConfigReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateConfigReq {
	id          string @[json: 'id']
	key         ?string @[json: 'key']
	value       ?string @[json: 'value']
	category    ?string @[json: 'category']
	description ?string @[json: 'description']
	status      ?u8 @[json: 'status']
}

pub struct UpdateConfigResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_config_repo(mut ctx Context, req UpdateConfigReq) !UpdateConfigResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.key {
			key == v
		},
		if v := req.value {
			value == v
		},
		if v := req.category {
			category == v
		},
		if v := req.description {
			description == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update PfConfig set up_expr where id == req.id
	}!
	return UpdateConfigResp{
		msg: 'Configuration updated'
	}
}
