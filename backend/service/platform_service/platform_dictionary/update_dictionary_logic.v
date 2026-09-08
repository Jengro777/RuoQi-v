module platform_dictionary

import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfDictionary }
import common.api

// ═══ Handler ═══
@['/update_dictionary'; post]
pub fn (app &PlatformDictionary) update_dictionary_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateDictionaryReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_dictionary_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_dictionary_usecase(mut ctx Context, req UpdateDictionaryReq) !UpdateDictionaryResp {
	update_dictionary_domain(req)!
	return update_dictionary_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_dictionary_domain(req UpdateDictionaryReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateDictionaryReq {
	id          string @[json: 'id']
	name        ?string @[json: 'name']
	code        ?string @[json: 'code']
	description ?string @[json: 'description']
	status      ?u8 @[json: 'status']
}

pub struct UpdateDictionaryResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_dictionary_repo(mut ctx Context, req UpdateDictionaryReq) !UpdateDictionaryResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr :=
		sql {
		}
	sql db {
		dynamic update PfDictionary set up_expr where id == req.id
	}!
	return UpdateDictionaryResp{
		msg: 'Dictionary updated'
	}
}
