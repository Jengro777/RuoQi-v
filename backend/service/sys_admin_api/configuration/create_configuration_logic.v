module configuration

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_sys { SysConfiguration }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Configuration) create_configuration_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateConfigurationReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_configuration_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_configuration_usecase(mut ctx Context, req CreateConfigurationReq) !CreateConfigurationResp {
	// Domain 校验
	create_configuration_domain(req)!

	// Repository 写入数据库
	return create_configuration_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_configuration_domain(req CreateConfigurationReq) ! {
	if req.name == '' {
		return error('name is required')
	}
	if req.key == '' {
		return error('key is required')
	}
	if req.value == '' {
		return error('value is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateConfigurationReq {
	name       string     @[json: 'name']
	status     u8         @[json: 'status']
	key        string     @[json: 'key']
	value      string     @[json: 'value']
	sort       u32        @[json: 'sort']
	category   string     @[json: 'category']
	remark     string     @[json: 'remark']
	created_at ?time.Time @[json: 'createdAt']
	updated_at ?time.Time @[json: 'updatedAt']
}

pub struct CreateConfigurationResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_configuration_repo(mut ctx Context, req CreateConfigurationReq) !CreateConfigurationResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	config := SysConfiguration{
		id:         rand.uuid_v7()
		name:       req.name
		status:     req.status
		key:        req.key
		value:      req.value
		sort:       req.sort
		category:   req.category
		remark:     req.remark
		created_at: req.created_at or { time.now() }
		updated_at: req.updated_at or { time.now() }
	}

	sql db {
		insert config into SysConfiguration
	} or { return error('Failed to execute SQL query: ${err}') }

	return CreateConfigurationResp{
		msg: 'Configuration created successfully'
	}
}
