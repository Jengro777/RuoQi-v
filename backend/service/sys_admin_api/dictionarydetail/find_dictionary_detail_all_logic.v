module dictionarydetail

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/all'; post]
pub fn (app &DictionaryDetail) find_dictionary_detail_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DictionaryDetailListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_dictionary_detail_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn find_dictionary_detail_all_usecase(mut ctx Context, req DictionaryDetailListReq) !DictionaryDetailListResp {
	find_dictionary_detail_all_domain(req)!
	return find_dictionary_detail_all_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn find_dictionary_detail_all_domain(req DictionaryDetailListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct DictionaryDetailListReq {
	page          int     @[json: 'page']
	page_size     int     @[json: 'pageSize']
	dictionary_id ?string @[json: 'dictionaryId']
	key           ?string @[json: 'key']
	status        ?u8     @[json: 'status']
}

pub struct DictionaryDetailListItem {
	id            string @[json: 'id']
	title         string @[json: 'title']
	trans         string @[json: 'trans']
	key           string @[json: 'key']
	value         string @[json: 'value']
	dictionary_id string @[json: 'dictionaryId']
	sort          int    @[json: 'sort']
	status        u8     @[json: 'status']
	created_at    string @[json: 'createdAt']
	updated_at    string @[json: 'updatedAt']
	deleted_at    string @[json: 'deletedAt']
}

pub struct DictionaryDetailListResp {
	total int                        @[json: 'total']
	data  []DictionaryDetailListItem @[json: 'data']
}

// ----------------- Repository 层 -----------------
fn find_dictionary_detail_all_repo(mut ctx Context, req DictionaryDetailListReq) !DictionaryDetailListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from SysDictionaryDetail
	}!

	offset_num := (req.page - 1) * req.page_size

	// 条件过滤
	wh_expr := {
		if dictionary_id := req.dictionary_id {
			dictionary_id == dictionary_id
		},
		if key := req.key {
			key == key
		},
		if status := req.status {
			status == status
		}
	}
	mut result := sql db {
		dynamic select from SysDictionaryDetail where wh_expr limit req.page_size offset offset_num
	}!

	mut datalist := []DictionaryDetailListItem{}
	for row in result {
		datalist << DictionaryDetailListItem{
			id:            row.id
			title:         row.title
			trans:         row.title
			key:           row.key
			value:         row.value
			dictionary_id: row.dictionary_id
			sort:          int(row.sort)
			status:        row.status
			created_at:    row.created_at.format_ss()
			updated_at:    row.updated_at.format_ss()
			deleted_at:    row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return DictionaryDetailListResp{
		total: count
		data:  datalist
	}
}
