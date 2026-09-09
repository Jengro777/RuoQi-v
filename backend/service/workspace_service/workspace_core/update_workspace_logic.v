module workspace_core

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_workspace { WsWorkspace }
import common.api

// ═══ Handler ═══
@['/update_workspace'; post]
pub fn (app &WorkspaceCore) update_workspace_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateWsReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_workspace_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_workspace_usecase(mut ctx Context, req UpdateWsReq) !UpdateWsResp {
	update_workspace_domain(req)!
	return update_workspace_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_workspace_domain(req UpdateWsReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateWsReq {
	id          string @[json: 'id']
	name        ?string @[json: 'name']
	description ?string @[json: 'description']
	status      ?u8 @[json: 'status']
}

pub struct UpdateWsResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_workspace_repo(mut ctx Context, req UpdateWsReq) !UpdateWsResp {
	ctx.scope_sc.workspace_id = req.id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.name {
			name == v
		},
		if v := req.description {
			description == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update WsWorkspace set up_expr where id == req.id && del_flag == 0
	} or { return error('Failed to update workspace: ${err}') }
	return UpdateWsResp{
		msg: 'Workspace updated'
	}
}
