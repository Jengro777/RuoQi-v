module platform_dictionary

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfDictionaryDetail }
import common.api

// ═══ Handler ═══
@['/create_detail'; post]
pub fn (app &PlatformDictionary) create_detail_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_detail_usecase(mut ctx Context, req CreateDetailReq) !CreateDetailResp {
	create_detail_domain(req)!
	return create_detail_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_detail_domain(req CreateDetailReq) ! {
	if req.dictionary_id == '' { return error('dictionary_id is required') }
}

// ═══ DTO ═══
pub struct CreateDetailReq {
	dictionary_id string @[json: 'dictionaryId']
	label         string @[json: 'label']
	value         string @[json: 'value']
	sort          u32    @[json: 'sort']
}

pub struct CreateDetailResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_detail_repo(mut ctx Context, req CreateDetailReq) !CreateDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	d := PfDictionaryDetail{
		id:            rand.uuid_v7()
		dictionary_id: req.dictionary_id
		label:         req.label
		value:         req.value
		sort:          req.sort
		status:        0
		created_at:    time.now()
		updated_at:    time.now()
	}
	sql db {
		insert d into PfDictionaryDetail
	} or { return error('Failed: ${err}') }
	return CreateDetailResp{
		id:  d.id
		msg: 'Detail created'
	}
}
