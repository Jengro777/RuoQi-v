module workspace_core

import veb
import log
import json2 as json
import model { Context }
import model.schema_workspace { WsRoleApi }
import common.api

// ═══ Handler ═══
@['/find_role_apis'; post]
pub fn (app &WorkspaceCore) find_role_apis_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindRolePermReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := find_role_apis_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_role_apis_usecase(mut ctx Context, req FindRolePermReq) ![]WsRoleApi {
	find_role_apis_domain(req)!
	return find_role_apis_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_role_apis_domain(req FindRolePermReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ═══ DTO ═══
pub struct FindRolePermReq {
	workspace_id string @[json: 'workspaceId']
	role_id      string @[json: 'roleId']
}

// ═══ Repository ═══
fn find_role_apis_repo(mut ctx Context, req FindRolePermReq) ![]WsRoleApi {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	result := sql db {
		select from WsRoleApi where workspace_id == req.workspace_id && role_id == req.role_id
	} or { return error('Failed: ${err}') }
	return result
}
