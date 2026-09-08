module platform_dictionary

import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfDictionaryDetail }
import common.api

// ═══ Handler ═══
@['/update_detail'; post]
pub fn (app &PlatformDictionary) update_detail_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_detail_usecase(mut ctx Context, req UpdateDetailReq) !UpdateDetailResp {
	update_detail_domain(req)!
	return update_detail_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_detail_domain(req UpdateDetailReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateDetailReq {
	id     string @[json: 'id']
	label  ?string @[json: 'label']
	value  ?string @[json: 'value']
	sort   ?u32 @[json: 'sort']
	status ?u8 @[json: 'status']
}

pub struct UpdateDetailResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_detail_repo(mut ctx Context, req UpdateDetailReq) !UpdateDetailResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr :=
		sql {
		}
	sql db {
		dynamic update PfDictionaryDetail set up_expr where id == req.id
	}!
	return UpdateDetailResp{
		msg: 'Detail updated'
	}
}
