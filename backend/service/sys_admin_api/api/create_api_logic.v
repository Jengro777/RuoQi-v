module api

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_sys { SysApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Api) create_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_api_usecase(mut ctx Context, req CreateApiReq) !CreateApiResp {
	create_api_domain(req)!
	return create_api(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_api_domain(req CreateApiReq) ! {
	if req.path == '' {
		return error('path is required')
	}
	if req.method == '' {
		return error('method is required')
	}
	if req.service_name == '' {
		return error('service_name is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateApiReq {
	path         string  @[json: 'path']
	description  ?string @[json: 'description']
	api_group    string  @[json: 'group']
	service_name string  @[json: 'serviceName']
	method       string  @[json: 'method']
	is_required  ?bool = false   @[json: 'isRequired']
}

pub struct CreateApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_api(mut ctx Context, req CreateApiReq) !CreateApiResp {
	time_now := time.now()
	sys_api := SysApi{
		id:           rand.uuid_v7()
		path:         req.path
		description:  req.description
		api_group:    req.api_group
		service_name: req.service_name
		method:       req.method
		is_required:  u8(if req.is_required or { false } { 1 } else { 0 }) // true: 1 false: 0
		created_at:   time_now
		updated_at:   time_now
	}

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert sys_api into SysApi
	} or { return error('Failed to create API: ${err}') }

	return CreateApiResp{
		msg: 'API created successfully'
	}
}
