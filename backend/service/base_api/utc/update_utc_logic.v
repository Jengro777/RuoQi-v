module utc

import veb
import log
import json2 as json
import model.schema_base { BaseUtc }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Utc) update_utc_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateUtcReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_utc_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
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
	id              string @[json: 'id']
	sort            ?int @[json: 'sort']
	name            ?string @[json: 'name']
	lng_range_start ?f64 @[json: 'lngRangeStart']
	lng_range_end   ?f64 @[json: 'lngRangeEnd']
	lng_mid         ?f64 @[json: 'lngMid']
}

pub struct UpdateUtcResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_utc_repo(mut ctx Context, req UpdateUtcReq) !UpdateUtcResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr :=
		sql {
		}

	sql db {
		dynamic update BaseUtc set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateUtcResp{
		msg: 'UTC updated successfully'
	}
}
