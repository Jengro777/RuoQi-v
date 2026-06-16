module platform_dictionary

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfDictionary }
import common.api

// ═══ Handler ═══
@['/create_dictionary'; post]
pub fn (app &PlatformDictionary) create_dictionary_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateDictionaryReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_dictionary_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_dictionary_usecase(mut ctx Context, req CreateDictionaryReq) !CreateDictionaryResp {
	create_dictionary_domain(req)!
	return create_dictionary_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_dictionary_domain(req CreateDictionaryReq) ! {
	if req.name == '' { return error('name is required') }
}

// ═══ DTO ═══
pub struct CreateDictionaryReq {
	name        string @[json: 'name']
	code        string @[json: 'code']
	description string @[json: 'description']
}

pub struct CreateDictionaryResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_dictionary_repo(mut ctx Context, req CreateDictionaryReq) !CreateDictionaryResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	d := PfDictionary{
		id:          rand.uuid_v7()
		name:        req.name
		code:        req.code
		description: req.description
		status:      0
		created_at:  time.now()
		updated_at:  time.now()
	}
	sql db {
		insert d into PfDictionary
	} or { return error('Failed: ${err}') }
	return CreateDictionaryResp{
		id:  d.id
		msg: 'Dictionary created'
	}
}
