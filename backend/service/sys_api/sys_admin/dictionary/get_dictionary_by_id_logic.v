module dictionary

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysDictionary }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/dictionary/get_by_id'; post]
pub fn(app &Dictionary)dictionary_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DictionaryByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := dictionary_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn dictionary_by_id_usecase(mut ctx Context, req DictionaryByIdReq) !DictionaryByIdResp {
	dictionary_by_id_domain(req)!
	return dictionary_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn dictionary_by_id_domain(req DictionaryByIdReq) ! {
	if req.id == '' {
		return error('dictionary id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DictionaryByIdReq {
	id string @[json: 'id']
}

pub struct DictionaryByIdResp {
	id         string @[json: 'id']
	title      string @[json: 'title']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	desc       string @[json: 'desc']
	created_at string @[json: 'created_at']
	updated_at string @[json: 'updated_at']
	deleted_at string @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn dictionary_by_id_repo(mut ctx Context, req DictionaryByIdReq) !DictionaryByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDictionary](db)
	query := q.select()!.where('id = ?', req.id)!
	result := query.query()!

	if result.len == 0 {
		return error('dictionary not found')
	}

	row := result[0]

	return DictionaryByIdResp{
		id:         row.id
		title:      row.title
		status:     int(row.status)
		name:       row.name
		desc:       row.desc or { '' }
		created_at: row.created_at.format_ss()
		updated_at: row.updated_at.format_ss()
		deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
	}
}
