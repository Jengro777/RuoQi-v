module api

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Api) update_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := update_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_api_usecase(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	update_api_domain(req)!
	return update_api(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_api_domain(req UpdateApiReq) ! {
	if req.id == '' {
		return error('id is required')
	}
	if req.path == '' {
		return error('path is required')
	}
	if req.method == '' {
		return error('method is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateApiReq {
	id           string     @[json: 'id']
	path         string     @[json: 'path']
	description  string     @[json: 'description']
	api_group    string     @[json: 'group']
	service_name string     @[json: 'service_name']
	trans        string     @[json: 'trans']
	method       string     @[json: 'method']
	is_required  u8         @[json: 'isRequired']
	updated_at   ?time.Time @[json: 'updatedAt']
}

pub struct UpdateApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_api(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysApi](db)

	q.set('path = ?', req.path)!
		.set('description = ?', req.description)!
		.set('api_group = ?', req.api_group)!
		.set('service_name = ?', req.service_name)!
		.set('method = ?', req.method)!
		.set('is_required = ?', req.is_required)!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateApiResp{
		msg: '更新成功'
	}
}
