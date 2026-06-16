module platform_dictionary

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfDictionaryDetail }
import common.api

// ═══ Handler ═══
@['/find_detail_by_dict'; post]
pub fn (app &PlatformDictionary) find_detail_by_dict_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindDetailByDictReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_detail_by_dict_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_detail_by_dict_usecase(mut ctx Context, req FindDetailByDictReq) ![]PfDictionaryDetail {
	find_detail_by_dict_domain(req)!
	return find_detail_by_dict_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_detail_by_dict_domain(req FindDetailByDictReq) ! {
	if req.dictionary_id == '' { return error('dictionary_id is required') }
}

// ═══ DTO ═══
pub struct FindDetailByDictReq {
	dictionary_id string @[json: 'dictionaryId']
}

// ═══ Repository ═══
fn find_detail_by_dict_repo(mut ctx Context, req FindDetailByDictReq) ![]PfDictionaryDetail {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	details := sql db {
		select from PfDictionaryDetail where dictionary_id == req.dictionary_id && del_flag == 0 order by sort
	} or { return error('Failed: ${err}') }
	return details
}
