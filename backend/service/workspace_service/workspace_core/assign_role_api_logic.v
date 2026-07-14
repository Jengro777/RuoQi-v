module workspace_core

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_workspace { WsRoleApi }
import common.api

// ═══ Handler ═══
@['/assign_role_api'; post]
pub fn (app &WorkspaceCore) assign_role_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[AssignRoleApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := assign_role_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn assign_role_api_usecase(mut ctx Context, req AssignRoleApiReq) !AssignRoleApiResp {
	assign_role_api_domain(req)!
	return assign_role_api_repo(mut ctx, req)
}

// ═══ Domain ═══
fn assign_role_api_domain(req AssignRoleApiReq) ! {
	if req.workspace_id == '' { return error('workspace_id is required') }
	if req.role_id == '' { return error('role_id is required') }
}

// ═══ DTO ═══
pub struct AssignRoleApiReq {
	workspace_id string   @[json: 'workspaceId']
	role_id      string   @[json: 'roleId']
	api_ids      []string @[json: 'apiIds']
	source_type  string   @[json: 'sourceType']
	source_id    string   @[json: 'sourceId']
}

pub struct AssignRoleApiResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn assign_role_api_repo(mut ctx Context, req AssignRoleApiReq) !AssignRoleApiResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from WsRoleApi where workspace_id == req.workspace_id && role_id == req.role_id
	}!
	for api_id in req.api_ids {
		ra := WsRoleApi{
			workspace_id: req.workspace_id
			role_id:      req.role_id
			api_id:       api_id
			source_type:  req.source_type
			source_id:    req.source_id
		}
		sql db {
			insert ra into WsRoleApi
		}!
	}
	return AssignRoleApiResp{
		msg: 'Role API assigned'
	}
}
