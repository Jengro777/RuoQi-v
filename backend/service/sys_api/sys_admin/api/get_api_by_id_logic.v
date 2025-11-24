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
@['/api/id'; post]
pub fn(app &Api)api_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetApiByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_api_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_api_by_id_usecase(mut ctx Context, req GetApiByIdReq) !GetApiByIdResp {
	// Domain 校验
	validate_api_by_id_domain(req)!

	// Repository 查询
	return get_api_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn validate_api_by_id_domain(req GetApiByIdReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetApiByIdReq {
	id string @[json: 'id']
}

pub struct GetApiByIdResp {
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
fn get_api_by_id_repo(mut ctx Context, req GetApiByIdReq) !GetApiByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysApi](db)
	mut query := q.select()!.where('id = ?', req.id)!
	result := query.query()!

	if result.len == 0 {
		return error('API with id=${req.id} not found')
	}

	row := result[0]

	return GetApiByIdResp{
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
