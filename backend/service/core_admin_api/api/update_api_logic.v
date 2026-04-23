module api

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_core { CoreApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/update'; post]
pub fn (app &Api)api_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateCoreApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_api_usecase(mut ctx Context, req UpdateCoreApiReq) !UpdateCoreApiResp {
	// Domain 参数校验
	update_api_domain(req)!

	// Repository 执行更新
	return update_api_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_api_domain(req UpdateCoreApiReq) ! {
	if req.id == '' {
		return error('id is required')
	}
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
pub struct UpdateCoreApiReq {
	id           string     @[json: 'id'; required]
	path         string     @[json: 'path'; required]
	description  ?string    @[json: 'description']
	api_group    string     @[json: 'api_group'; required]
	service_name string     @[json: 'service_name'; required]
	method       string     @[json: 'method'; required]
	is_required  u8         @[default: 0; json: 'is_required'; required]
	source_type  string     @[json: 'source_type'; required]
	source_id    string     @[json: 'source_id'; required]
	updated_at   ?time.Time @[json: 'updated_at']
}

pub struct UpdateCoreApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_api_repo(mut ctx Context, req UpdateCoreApiReq) !UpdateCoreApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q_api := orm.new_query[CoreApi](db)

	q_api.set('path = ?', req.path)!
		.set('description = ?', req.description or { '' })!
		.set('api_group = ?', req.api_group)!
		.set('service_name = ?', req.service_name)!
		.set('method = ?', req.method)!
		.set('is_required = ?', req.is_required)!
		.set('source_type = ?', req.source_type)!
		.set('source_id = ?', req.source_id)!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateCoreApiResp{
		msg: 'API updated successfully'
	}
}
