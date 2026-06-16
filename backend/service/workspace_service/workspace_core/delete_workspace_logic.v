module workspace_core

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsWorkspace }
import common.api

// ═══ Handler ═══
@['/delete_workspace'; post]
pub fn (app &WorkspaceCore) delete_workspace_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteWsReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_workspace_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_workspace_usecase(mut ctx Context, req DeleteWsReq) !DeleteWsResp {
	delete_workspace_domain(req)!
	return delete_workspace_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_workspace_domain(req DeleteWsReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct DeleteWsReq {
	id string @[json: 'id']
}

pub struct DeleteWsResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_workspace_repo(mut ctx Context, req DeleteWsReq) !DeleteWsResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update WsWorkspace set del_flag = 1 where id == req.id
	}!
	return DeleteWsResp{
		msg: 'Workspace deleted'
	}
}
