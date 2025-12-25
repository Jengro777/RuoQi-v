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
@['/list'; post]
pub fn (app &Api) get_api_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[ApiListPageReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := api_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn api_list_usecase(mut ctx Context, req ApiListPageReq) !ApiListPageResp {
	api_list_domain(req)!

	return get_api_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn api_list_domain(req ApiListPageReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct ApiListPageReq {
	page         int    @[json: 'page']
	page_size    int    @[json: 'pageSize']
	path         string @[json: 'path']
	api_group    string @[json: 'group']
	service_name string @[json: 'serviceName']
	method       string @[json: 'method']
	is_required  u8     @[json: 'isRequired']
	description  string @[json: 'description']
}

pub struct ApiListPageResp {
	total int           @[json: 'total']
	data  []ApiListData @[json: 'data']
}

pub struct ApiListData {
	id           string @[json: 'id']
	trans        string @[json: 'trans']
	path         string @[json: 'path']
	description  string @[json: 'description']
	api_group    string @[json: 'group']
	method       string @[json: 'method']
	is_required  bool   @[json: 'isRequired']
	service_name string @[json: 'serviceName']
	created_at   string @[json: 'createdAt']
	updated_at   string @[json: 'updatedAt']
	deleted_at   string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn get_api_list(mut ctx Context, req ApiListPageReq) !ApiListPageResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
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

	if req.method != '' {
		q = q.where('method = ?', req.method)!
	}

	result := q.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []ApiListData{}
	for row in result {
		datalist << ApiListData{
			id:           row.id
			trans:        row.description or { '' }
			path:         row.path
			description:  row.description or { '' }
			api_group:    row.api_group
			method:       row.method
			is_required:  if row.is_required == 1 { true } else { false } // true: 1 false: 0
			service_name: row.service_name
			created_at:   row.created_at.format_ss()
			updated_at:   row.updated_at.format_ss()
			deleted_at:   (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return ApiListPageResp{
		total: count
		data:  datalist
	}
}
