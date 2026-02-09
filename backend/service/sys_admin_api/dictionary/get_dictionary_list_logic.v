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
@['/list'; post]
pub fn (app &Dictionary) dictionary_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetDictionaryListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_dictionary_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_dictionary_list_usecase(mut ctx Context, req GetDictionaryListReq) !GetDictionaryListResp {
	// Domain 校验
	get_dictionary_list_domain(req)!

	// Repository 查询
	return find_dictionary_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_dictionary_list_domain(req GetDictionaryListReq) ! {
	if req.page <= 0 {
		return error('page must be a positive integer')
	}
	if req.page_size <= 0 {
		return error('page_size must be a positive integer')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetDictionaryListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'pageSize']
	name      string @[json: 'name']
}

pub struct DictionaryData {
	id         string @[json: 'id']
	title      string @[json: 'title']
	trans      string @[json: 'trans']
	name       string @[json: 'name']
	desc       string @[json: 'desc']
	status     u8     @[json: 'status']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

pub struct GetDictionaryListResp {
	total int
	data  []DictionaryData
}

// ----------------- Repository 层 -----------------
fn find_dictionary_list(mut ctx Context, req GetDictionaryListReq) !GetDictionaryListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	offset_num := (req.page - 1) * req.page_size

	mut q := orm.new_query[SysDictionary](db)
	mut query := q.select()!

	// 条件过滤
	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}

	// 总数统计
	mut count := sql db {
		select count from SysDictionary
	}!

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []DictionaryData{}
	for row in result {
		datalist << DictionaryData{
			id:         row.id
			title:      row.title
			trans:      row.title
			name:       row.name
			desc:       row.desc or { '' }
			status:     row.status
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return GetDictionaryListResp{
		total: count
		data:  datalist
	}
}
