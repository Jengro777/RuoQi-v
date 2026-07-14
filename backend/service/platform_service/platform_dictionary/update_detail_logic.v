module platform_dictionary

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_platform { PfDictionaryDetail }
import common.api

// ═══ Handler ═══
@['/update_detail'; post]
pub fn (app &PlatformDictionary) update_detail_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_detail_usecase(mut ctx Context, req UpdateDetailReq) !UpdateDetailResp {
	update_detail_domain(req)!
	return update_detail_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_detail_domain(req UpdateDetailReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct UpdateDetailReq {
	id     string  @[json: 'id']
	label  ?string @[json: 'label']
	value  ?string @[json: 'value']
	sort   ?u32    @[json: 'sort']
	status ?u8     @[json: 'status']
}

pub struct UpdateDetailResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_detail_repo(mut ctx Context, req UpdateDetailReq) !UpdateDetailResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if label := req.label { label == label },
		if value := req.value { value == value },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status }
	}
	sql db {
		dynamic update PfDictionaryDetail set up_expr where id == req.id
	}!
	return UpdateDetailResp{
		msg: 'Detail updated'
	}
}
