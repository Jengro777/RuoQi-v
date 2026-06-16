module platform_configuration

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfConfiguration }
import common.api

// ═══ Handler ═══
@['/create_config'; post]
pub fn (app &PlatformConfiguration) create_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateConfigReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_config_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_config_usecase(mut ctx Context, req CreateConfigReq) !CreateConfigResp {
	create_config_domain(req)!
	return create_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_config_domain(req CreateConfigReq) ! {
	if req.key == '' { return error('key is required') }
}

// ═══ DTO ═══
pub struct CreateConfigReq {
	key         string @[json: 'key']
	value       string @[json: 'value']
	category    string @[json: 'category']
	description string @[json: 'description']
}

pub struct CreateConfigResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_config_repo(mut ctx Context, req CreateConfigReq) !CreateConfigResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	c := PfConfiguration{
		id:          rand.uuid_v7()
		key:         req.key
		value:       req.value
		category:    req.category
		description: req.description
		status:      0
		created_at:  time.now()
		updated_at:  time.now()
	}
	sql db {
		insert c into PfConfiguration
	} or { return error('Failed: ${err}') }
	return CreateConfigResp{
		id:  c.id
		msg: 'Configuration created'
	}
}
