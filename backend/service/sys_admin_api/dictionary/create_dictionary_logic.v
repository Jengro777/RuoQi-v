module dictionary

import veb
import log
import orm
import time
import rand
import x.json2 as json
import structs.schema_sys { SysDictionary }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Dictionary) dictionary_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateDictionaryReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_dictionary_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_dictionary_usecase(mut ctx Context, req CreateDictionaryReq) !CreateDictionaryResp {
	// Domain 校验
	create_dictionary_domain(req)!

	// Repository 写入数据库
	return create_dictionary_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_dictionary_domain(req CreateDictionaryReq) ! {
	if req.title == '' {
		return error('title is required')
	}
	if req.name == '' {
		return error('name is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateDictionaryReq {
	title      string     @[json: 'title']
	name       string     @[json: 'name']
	desc       string     @[json: 'desc']
	status     u8         @[json: 'status']
	created_at ?time.Time @[json: 'createdAt']
	updated_at ?time.Time @[json: 'updatedAt']
}

pub struct CreateDictionaryResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_dictionary_repo(mut ctx Context, req CreateDictionaryReq) !CreateDictionaryResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysDictionary](db)

	dict := SysDictionary{
		id:         rand.uuid_v7()
		title:      req.title
		name:       req.name
		desc:       req.desc
		status:     req.status
		created_at: time.now()
		updated_at: time.now()
	}

	q.insert(dict)!

	return CreateDictionaryResp{
		msg: 'Dictionary created successfully'
	}
}
