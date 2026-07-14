module platform_api

import veb
import log
import time
import rand
import json2 as json
import structs { Context }
import structs.schema_platform { PfApi }
import common.api as capi

// ═══ Handler ═══
@['/create_api'; post]
pub fn (app &PlatformApi) create_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateApiReq](ctx.req.data) or {
		return ctx.json(capi.json_error_400(err.msg()))
	}
	result := create_api_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_api_usecase(mut ctx Context, req CreateApiReq) !CreateApiResp {
	create_api_domain(req)!
	return create_api_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_api_domain(req CreateApiReq) ! {
	if req.path == '' { return error('path is required') }
}

// ═══ DTO ═══
pub struct CreateApiReq {
	path         string  @[json: 'path']
	description  ?string @[json: 'description']
	api_group    string  @[json: 'apiGroup']
	service_name string  @[json: 'serviceName']
	method       string  @[json: 'method']
	is_required  u8      @[json: 'isRequired']
}

pub struct CreateApiResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_api_repo(mut ctx Context, req CreateApiReq) !CreateApiResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	api := PfApi{
		id:           rand.uuid_v7()
		path:         req.path
		description:  req.description
		api_group:    req.api_group
		service_name: req.service_name
		method:       req.method
		is_required:  req.is_required
		status:       0
		created_at:   time.now()
		updated_at:   time.now()
	}
	sql db {
		insert api into PfApi
	} or { return error('Failed: ${err}') }
	return CreateApiResp{
		id:  api.id
		msg: 'API created'
	}
}
