module workspace_core

import veb
import log
import time
import rand
import json2 as json
import model { Context }
import model.schema_workspace { WsWorkspace }
import common.api

// ═══ Handler ═══
@['/create_workspace'; post]
pub fn (app &WorkspaceCore) create_workspace_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateWsReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := create_workspace_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_workspace_usecase(mut ctx Context, req CreateWsReq) !CreateWsResp {
	create_workspace_domain(req)!
	return create_workspace_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_workspace_domain(req CreateWsReq) ! {
	if req.name == '' {
		return error('name is required')
	}
	if req.tenant_id == '' {
		return error('tenant_id is required')
	}
}

// ═══ DTO ═══
pub struct CreateWsReq {
	tenant_id   string @[json: 'tenantId']
	name        string @[json: 'name']
	description string @[json: 'description']
}

pub struct CreateWsResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_workspace_repo(mut ctx Context, req CreateWsReq) !CreateWsResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	w := WsWorkspace{
		id: rand.uuid_v7()
		tenant_id: req.tenant_id
		name: req.name
		description: req.description
		status: 1
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert w into WsWorkspace
	} or { return error('Failed: ${err}') }
	return CreateWsResp{
		id: w.id
		msg: 'Workspace created'
	}
}
