module platform_dictionary

import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfDictionaryDetail }
import common.api

// ═══ Handler ═══
@['/delete_detail'; post]
pub fn (app &PlatformDictionary) delete_detail_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_detail_usecase(mut ctx Context, req DeleteDetailReq) !DeleteDetailResp {
	delete_detail_domain(req)!
	return delete_detail_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_detail_domain(req DeleteDetailReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct DeleteDetailReq {
	id string @[json: 'id']
}

pub struct DeleteDetailResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_detail_repo(mut ctx Context, req DeleteDetailReq) !DeleteDetailResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update PfDictionaryDetail set del_flag = -1 where id == req.id
	}!
	return DeleteDetailResp{
		msg: 'Detail deleted'
	}
}
