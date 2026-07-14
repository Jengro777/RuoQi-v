module utc

import veb
import log
import json2 as json
import structs.schema_base { BaseUtc }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Utc) update_utc_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateUtcReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_utc_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_utc_usecase(mut ctx Context, req UpdateUtcReq) !UpdateUtcResp {
	// Domain 校验
	update_utc_domain(req)!

	// Repository 更新
	return update_utc_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_utc_domain(req UpdateUtcReq) ! {
	if req.id == '' {
		return error('currency id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateUtcReq {
	id              string  @[json: 'id']
	sort            ?int    @[json: 'sort']
	name            ?string @[json: 'name']
	lng_range_start ?f64    @[json: 'lngRangeStart']
	lng_range_end   ?f64    @[json: 'lngRangeEnd']
	lng_mid         ?f64    @[json: 'lngMid']
}

pub struct UpdateUtcResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_utc_repo(mut ctx Context, req UpdateUtcReq) !UpdateUtcResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if sort := req.sort { sort == sort },
		if name := req.name { name == name },
		if lng_range_start := req.lng_range_start { lng_range_start == lng_range_start },
		if lng_range_end := req.lng_range_end { lng_range_end == lng_range_end },
		if lng_mid := req.lng_mid { lng_mid == lng_mid }
	}

	sql db {
		dynamic update BaseUtc set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateUtcResp{
		msg: 'UTC updated successfully'
	}
}
