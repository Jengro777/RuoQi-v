module workspace_position

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_workspace { WsPosition }
import common.api

// ═══ Handler ═══
@['/delete_position'; post]
pub fn (app &WorkspacePosition) delete_position_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeletePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_position_usecase(mut ctx Context, req DeletePositionReq) !DeletePositionResp {
	delete_position_domain(req)!
	return delete_position_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_position_domain(req DeletePositionReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct DeletePositionReq {
	id string @[json: 'id']
}

pub struct DeletePositionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_position_repo(mut ctx Context, req DeletePositionReq) !DeletePositionResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update WsPosition set del_flag = -1, updated_at = time.now() where id == req.id
		&& del_flag == 0
	} or { return error('Failed to delete position: ${err}') }
	return DeletePositionResp{
		msg: 'Position deleted'
	}
}
