module platform_dictionary

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfDictionary }
import common.api

// ═══ Handler ═══
@['/delete_dictionary'; post]
pub fn (app &PlatformDictionary) delete_dictionary_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteDictionaryReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_dictionary_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_dictionary_usecase(mut ctx Context, req DeleteDictionaryReq) !DeleteDictionaryResp {
	delete_dictionary_domain(req)!
	return delete_dictionary_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_dictionary_domain(req DeleteDictionaryReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct DeleteDictionaryReq {
	id string @[json: 'id']
}

pub struct DeleteDictionaryResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_dictionary_repo(mut ctx Context, req DeleteDictionaryReq) !DeleteDictionaryResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update PfDictionary set del_flag = 1 where id == req.id
	}!
	return DeleteDictionaryResp{
		msg: 'Dictionary deleted'
	}
}
