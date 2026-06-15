module platform_configuration

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfConfiguration }
import common.api

// ═══ Handler ═══
@['/update_config'; post]
pub fn (app &PlatformConfiguration) update_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateConfigReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_config_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_config_usecase(mut ctx Context, req UpdateConfigReq) !UpdateConfigResp {
	update_config_domain(req)!
	return update_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_config_domain(req UpdateConfigReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct UpdateConfigReq {
	id          string  @[json: 'id']
	key         ?string @[json: 'key']
	value       ?string @[json: 'value']
	category    ?string @[json: 'category']
	description ?string @[json: 'description']
	status      ?u8     @[json: 'status']
}

pub struct UpdateConfigResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_config_repo(mut ctx Context, req UpdateConfigReq) !UpdateConfigResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if key := req.key { key == key },
		if value := req.value { value == value },
		if category := req.category { category == category },
		if description := req.description { description == description },
		if status := req.status { status == status }
	}
	sql db {
		dynamic update PfConfiguration set up_expr where id == req.id
	}!
	return UpdateConfigResp{
		msg: 'Configuration updated'
	}
}
