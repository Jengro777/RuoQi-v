module api

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/list'; post]
pub fn(app &Api)api_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[ApiListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := api_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn api_list_usecase(mut ctx Context, req ApiListReq) !ApiListResp {
	// Domain 校验
	api_list_domain(req)!

	// Repository 获取数据
	return api_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn api_list_domain(req ApiListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct ApiListReq {
	page         int    @[json: 'page']
	page_size    int    @[json: 'page_size']
	path         string @[json: 'path']
	api_group    string @[json: 'api_group']
	service_name string @[json: 'service_name']
	method       string @[json: 'method']
	is_required  u8     @[json: 'is_required']
}

pub struct ApiListResp {
	total int           @[json: 'total']
	data  []ApiListData @[json: 'data']
}

pub struct ApiListData {
	id           string @[json: 'id']
	path         string @[json: 'path']
	description  string @[json: 'description']
	api_group    string @[json: 'api_group']
	method       string @[json: 'method']
	is_required  int    @[json: 'is_required']
	service_name string @[json: 'service_name']
	created_at   string @[json: 'created_at']
	updated_at   string @[json: 'updated_at']
	deleted_at   string @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn api_list_repo(mut ctx Context, req ApiListReq) !ApiListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from SysApi
	}!

	offset_num := (req.page - 1) * req.page_size
	mut q := orm.new_query[SysApi](db).select()!

	if req.path != '' {
		q = q.where('path = ?', req.path)!
	}
	if req.api_group != '' {
		q = q.where('api_group = ?', req.api_group)!
	}
	if req.service_name != '' {
		q = q.where('service_name = ?', req.service_name)!
	}
	if req.is_required in [0, 1] {
		q = q.where('is_required = ?', req.is_required)!
	}
	if req.method != '' {
		q = q.where('method = ?', req.method)!
	}

	result := q.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []ApiListData{}
	for row in result {
		datalist << ApiListData{
			id:           row.id
			path:         row.path
			description:  row.description or { '' }
			api_group:    row.api_group
			method:       row.method
			is_required:  int(row.is_required)
			service_name: row.service_name
			created_at:   row.created_at.format_ss()
			updated_at:   row.updated_at.format_ss()
			deleted_at:   (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return ApiListResp{
		total: count
		data:  datalist
	}
}
