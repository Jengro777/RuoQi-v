module platform_configuration

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_platform { PfConfiguration }
import common.api

// ═══ Handler ═══
@['/delete_config'; post]
pub fn (app &PlatformConfiguration) delete_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteConfigReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_config_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_config_usecase(mut ctx Context, req DeleteConfigReq) !DeleteConfigResp {
	delete_config_domain(req)!
	return delete_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_config_domain(req DeleteConfigReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct DeleteConfigReq {
	id string @[json: 'id']
}

pub struct DeleteConfigResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_config_repo(mut ctx Context, req DeleteConfigReq) !DeleteConfigResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update PfConfiguration set del_flag = 1 where id == req.id
	}!
	return DeleteConfigResp{
		msg: 'Configuration deleted'
	}
}
