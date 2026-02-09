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
@['/update'; post]
pub fn (app &Configuration) configuration_update_handler(mut ctx Context) veb.Result {
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
	if req.config_id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateConfigurationReq {
	config_id  string     @[json: 'id']
	name       string     @[json: 'name']
	key        string     @[json: 'key']
	value      string     @[json: 'value']
	category   string     @[json: 'category']
	remark     string     @[json: 'remark']
	status     bool       @[json: 'status']
	sort       u64        @[json: 'sort']
	updated_at ?time.Time @[json: 'updatedAt']
}

pub struct UpdateConfigurationResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_configuration_repo(mut ctx Context, req UpdateConfigurationReq) !UpdateConfigurationResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now().format_ss()
	mut q := orm.new_query[SysConfiguration](db)

	if req.name != '' {
		q.set('name = ?', req.name)!
	}
	if req.key != '' {
		q.set('key = ?', req.key)!
	}
	if req.value != '' {
		q.set('value = ?', req.value)!
	}
	if req.category != '' {
		q.set('category = ?', req.category)!
	}
	if req.remark != '' {
		q.set('remark = ?', req.remark)!
	}

	if req.sort != 0 {
		q.set('sort = ?', req.sort)!
	}

	q.set('status = ?', if req.status { 1 } else { 0 })!
		.set('updated_at = ?', time_now)!
		.where('id = ?', req.config_id)!
		.update()!

	return UpdateConfigurationResp{
		msg: 'Configuration updated successfully'
	}
}
