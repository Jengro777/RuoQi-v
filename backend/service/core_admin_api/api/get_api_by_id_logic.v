module api

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/id'; post]
pub fn (app &Api) api_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetCoreApiByIDReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_core_api_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_core_api_by_id_usecase(mut ctx Context, req GetCoreApiByIDReq) ![]GetCoreApiByIDResp {
	// Domain 层校验参数
	get_core_api_by_id_domain(req)!

	// Repository 查询数据
	return get_core_api_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_core_api_by_id_domain(req GetCoreApiByIDReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetCoreApiByIDReq {
	id string @[json: 'id'; required]
}

pub struct GetCoreApiByIDResp {
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
fn get_core_api_by_id_repo(mut ctx Context, req GetCoreApiByIDReq) ![]GetCoreApiByIDResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	where_expr := {
		if req.id != '' {
			id == req.id
		}
	}

	result := sql db {
		dynamic select from CoreApi where where_expr limit 1
	} or { return error('Failed to execute SQL query: ${err}') }

	if result.len == 0 {
		return error('API not found')
	}

	mut datalist := []GetCoreApiByIDResp{}
	for row in result {
		datalist << GetCoreApiByIDResp{
			id:           row.id
			path:         row.path
			description:  row.description
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

	return datalist
}
