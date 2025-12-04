module api

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_core { CoreApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/create'; post]
pub fn api_create_handler(app &Api, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateCoreApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_api_usecase(mut ctx Context, req CreateCoreApiReq) !CreateCoreApiResp {
	// Domain 校验
	create_api_domain(req)!

	// Repository 写入 DB
	return create_api_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_api_domain(req CreateCoreApiReq) ! {
	if req.path == '' {
		return error('path is required')
	}
	if req.api_group == '' {
		return error('api_group is required')
	}
	if req.service_name == '' {
		return error('service_name is required')
	}
	if req.method == '' {
		return error('method is required')
	}
	if req.source_type == '' {
		return error('source_type is required')
	}
	if req.source_id == '' {
		return error('source_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateCoreApiReq {
	id           string     @[json: 'id'; required]
	path         string     @[json: 'path'; required]
	description  ?string    @[json: 'description']
	api_group    string     @[json: 'api_group'; required]
	service_name string     @[json: 'service_name'; required]
	method       string     @[json: 'method'; required]
	is_required  u8         @[default: 0; json: 'is_required'; required]
	source_type  string     @[json: 'source_type'; required]
	source_id    string     @[json: 'source_id'; required]
	created_at   ?time.Time @[json: 'created_at']
	updated_at   ?time.Time @[json: 'updated_at']
}

pub struct CreateCoreApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_api_repo(mut ctx Context, req CreateCoreApiReq) !CreateCoreApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now()
	data := CoreApi{
		id:           rand.uuid_v7()
		path:         req.path
		description:  req.description or { '' }
		api_group:    req.api_group
		service_name: req.service_name
		method:       req.method
		is_required:  req.is_required
		source_type:  req.source_type
		source_id:    req.source_id
		created_at:   req.created_at or { time_now }
		updated_at:   req.updated_at or { time_now }
	}

	sql db {
		insert data into CoreApi
	} or { return error('Failed to insert api: ${err}') }

	return CreateCoreApiResp{
		msg: 'API created successfully'
	}
}
