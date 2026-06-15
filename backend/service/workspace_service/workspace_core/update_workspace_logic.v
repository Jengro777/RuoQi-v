module workspace_core

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsWorkspace }
import common.api

// ═══ Handler ═══
@['/update_workspace'; post]
pub fn (app &WorkspaceCore) update_workspace_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateWsReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_workspace_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_workspace_usecase(mut ctx Context, req UpdateWsReq) !UpdateWsResp {
	update_workspace_domain(req)!
	return update_workspace_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_workspace_domain(req UpdateWsReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct UpdateWsReq {
	id          string  @[json: 'id']
	name        ?string @[json: 'name']
	description ?string @[json: 'description']
	status      ?u8     @[json: 'status']
}

pub struct UpdateWsResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_workspace_repo(mut ctx Context, req UpdateWsReq) !UpdateWsResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if name := req.name { name == name },
		if description := req.description { description == description },
		if status := req.status { status == status }
	}
	sql db {
		dynamic update WsWorkspace set up_expr where id == req.id
	}!
	return UpdateWsResp{
		msg: 'Workspace updated'
	}
}
