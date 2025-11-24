module dictionarydetail

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/dictionarydetail/id'; post]
pub fn(app &DictionaryDetail)dictionarydetail_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DictionaryDetailByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := dictionarydetail_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn dictionarydetail_by_id_usecase(mut ctx Context, req DictionaryDetailByIdReq) !DictionaryDetailByIdResp {
	// Domain 校验
	dictionarydetail_by_id_domain(req)!

	// Repository 查询
	return dictionarydetail_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn dictionarydetail_by_id_domain(req DictionaryDetailByIdReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DictionaryDetailByIdReq {
	id string @[json: 'id']
}

pub struct DictionaryDetailByIdResp {
	id            string @[json: 'id']
	title         string @[json: 'title']
	status        int    @[json: 'status']
	key           string @[json: 'key']
	value         string @[json: 'value']
	dictionary_id string @[json: 'dictionary_id']
	sort          int    @[json: 'sort']
	created_at    string @[json: 'created_at']
	updated_at    string @[json: 'updated_at']
	deleted_at    string @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn dictionarydetail_by_id_repo(mut ctx Context, req DictionaryDetailByIdReq) !DictionaryDetailByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDictionaryDetail](db)
	mut query := q.select()!.where('id = ?', req.id)!
	result := query.query()!

	if result.len == 0 {
		return error('DictionaryDetail not found for id=${req.id}')
	}

	row := result[0]
	return DictionaryDetailByIdResp{
		id:            row.id
		title:         row.title
		status:        int(row.status)
		key:           row.key
		value:         row.value
		dictionary_id: row.dictionary_id
		sort:          int(row.sort)
		created_at:    row.created_at.format_ss()
		updated_at:    row.updated_at.format_ss()
		deleted_at:    row.deleted_at or { time.Time{} }.format_ss()
	}
}
