module api

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/list'; post]
pub fn (app &Api) api_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetCoreApiByListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_core_api_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn get_core_api_list_usecase(mut ctx Context, req GetCoreApiByListReq) !GetCoreApiByListResp {
	// Domain 校验
	get_core_api_list_domain(req)!

	// Repository 查询
	return find_core_api_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_core_api_list_domain(req GetCoreApiByListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetCoreApiByListReq {
	page         int    @[json: 'page']
	page_size    int    @[json: 'page_size']
	path         string @[json: 'path']
	api_group    string @[json: 'api_group']
	service_name string @[json: 'service_name']
	method       string @[json: 'method']
	is_required  u8     @[json: 'is_required']
}

pub struct GetCoreApiByListResp {
	total int
	data  []GetCoreApiByList
}

pub struct GetCoreApiByList {
	id           string     @[json: 'id']
	path         string     @[json: 'path']
	description  ?string    @[json: 'description']
	api_group    string     @[json: 'api_group']
	service_name string     @[json: 'service_name']
	method       string     @[json: 'method']
	is_required  u8         @[default: 0; json: 'is_required']
	source_type  string     @[json: 'source_type']
	source_id    string     @[json: 'source_id']
	created_at   ?time.Time @[json: 'created_at']
	updated_at   ?time.Time @[json: 'updated_at']
	deleted_at   ?time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn find_core_api_list_repo(mut ctx Context, req GetCoreApiByListReq) !GetCoreApiByListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数查询
	mut count := sql db {
		select count from CoreApi
	}!

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
  where_expr := {
      if req.path != '' { path == req.path },
      if req.api_group != '' { api_group == req.api_group },
      if req.service_name != '' { service_name == req.service_name },
      if req.is_required in [0, 1] { is_required == req.is_required },
      if req.method != '' { method == req.method }
  }
	// vfmt on

	result := sql db {
		dynamic select from CoreApi where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []GetCoreApiByList{}
	for row in result {
		datalist << GetCoreApiByList{
			id:           row.id
			path:         row.path
			description:  row.description or { '' }
			api_group:    row.api_group
			service_name: row.service_name
			method:       row.method
			is_required:  row.is_required
			source_type:  row.source_type
			source_id:    row.source_id
			created_at:   row.created_at
			updated_at:   row.updated_at
			deleted_at:   row.deleted_at
		}
	}

	return GetCoreApiByListResp{
		total: count
		data:  datalist
	}
}
