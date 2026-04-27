module dictionarydetail

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysDictionary, SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/detail'; post]
pub fn (app &DictionaryDetail) dictionarydetail_by_name_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetDictionaryDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_dictionary_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn get_dictionary_detail_usecase(mut ctx Context, req GetDictionaryDetailReq) !GetDictionaryDetailResp {
	// 参数校验
	get_dictionary_detail_domain(req)!

	// Repository 获取数据
	return get_dictionary_detail_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_dictionary_detail_domain(req GetDictionaryDetailReq) ! {
	if req.dictionary_name == '' {
		return error('dictionary_name is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetDictionaryDetailReq {
	dictionary_name string @[json: 'dictionary_name']
}

pub struct DictionaryDetailItem {
	id            string @[json: 'id']
	title         string @[json: 'title']
	status        int    @[json: 'status']
	key           string @[json: 'key']
	value         string @[json: 'value']
	dictionary_id string @[json: 'dictionaryId']
	sort          int    @[json: 'sort']
	created_at    string @[json: 'createdAt']
	updated_at    string @[json: 'updatedAt']
	deleted_at    string @[json: 'deletedAt']
}

pub struct GetDictionaryDetailResp {
	msg  string                 @[json: 'msg']
	data []DictionaryDetailItem @[json: 'data']
}

// ----------------- Repository 层 -----------------
fn get_dictionary_detail_repo(mut ctx Context, req GetDictionaryDetailReq) !GetDictionaryDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 查询字典ID

	mut dict_result := sql db {
		select id from SysDictionary where name == req.dictionary_name
	}!
	if dict_result.len == 0 {
		return GetDictionaryDetailResp{
			msg:  'Dictionary not found'
			data: []
		}
	}
	dictionary_id := dict_result[0].id

	// 查询字典明细
	mut detail_result := sql db {
		select from SysDictionaryDetail where dictionary_id == dictionary_id
	}!

	mut datalist := []DictionaryDetailItem{}
	for row in detail_result {
		datalist << DictionaryDetailItem{
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

	return GetDictionaryDetailResp{
		msg:  'Success'
		data: datalist
	}
}
