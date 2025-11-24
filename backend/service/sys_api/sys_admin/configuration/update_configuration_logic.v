module configuration

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysConfiguration }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/configuration/update'; post]
pub fn(app &Configuration)configuration_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateConfigurationReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_configuration_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_configuration_usecase(mut ctx Context, req UpdateConfigurationReq) !UpdateConfigurationResp {
	// Domain 参数校验
	update_configuration_domain(req)!

	// Repository 写入数据库
	return update_configuration_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_configuration_domain(req UpdateConfigurationReq) ! {
	if req.id == '' {
		return error('id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
	if req.key == '' {
		return error('key is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateConfigurationReq {
	id         string     @[json: 'id']
	name       string     @[json: 'name']
	key        string     @[json: 'key']
	value      string     @[json: 'value']
	category   string     @[json: 'category']
	remark     string     @[json: 'remark']
	status     u8         @[json: 'status']
	sort       u64        @[json: 'sort']
	updated_at ?time.Time @[json: 'updated_at']
}

pub struct UpdateConfigurationResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_configuration_repo(mut ctx Context, req UpdateConfigurationReq) !UpdateConfigurationResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysConfiguration](db)

	q.set('name = ?', req.name)!
		.set('key = ?', req.key)!
		.set('value = ?', req.value)!
		.set('category = ?', req.category)!
		.set('remark = ?', req.remark)!
		.set('status = ?', req.status)!
		.set('sort = ?', req.sort)!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateConfigurationResp{
		msg: 'Configuration updated successfully'
	}
}
