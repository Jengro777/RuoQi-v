module dictionarydetail

import veb
import log
import orm
import time
import rand
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/dictionarydetail/create'; post]
pub fn (app &DictionaryDetail) dictionarydetail_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateDictionaryDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_dictionarydetail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_dictionarydetail_usecase(mut ctx Context, req CreateDictionaryDetailReq) !CreateDictionaryDetailResp {
	// Domain 校验
	create_dictionarydetail_domain(req)!

	// Repository 插入数据
	return create_dictionarydetail_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_dictionarydetail_domain(req CreateDictionaryDetailReq) ! {
	if req.dictionary_id == '' {
		return error('dictionary_id is required')
	}
	if req.key == '' {
		return error('key is required')
	}
	if req.value == '' {
		return error('value is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateDictionaryDetailReq {
	title         string     @[json: 'title']
	key           string     @[json: 'key']
	value         string     @[json: 'value']
	dictionary_id string     @[json: 'dictionary_id']
	sort          u32        @[json: 'sort']
	status        u8         @[json: 'status']
	created_at    ?time.Time @[json: 'created_at']
	updated_at    ?time.Time @[json: 'updated_at']
}

pub struct CreateDictionaryDetailResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_dictionarydetail_repo(mut ctx Context, req CreateDictionaryDetailReq) !CreateDictionaryDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysDictionaryDetail](db)

	detail := SysDictionaryDetail{
		id:            rand.uuid_v7()
		title:         req.title
		key:           req.key
		value:         req.value
		dictionary_id: req.dictionary_id
		sort:          req.sort
		status:        req.status
		created_at:    req.created_at or { time.now() }
		updated_at:    req.updated_at or { time.now() }
	}

	q.insert(detail)!

	return CreateDictionaryDetailResp{
		msg: 'Dictionary detail created successfully'
	}
}
