module workspace_core

import veb
import log
import json2 as json
import model { Context }
import model.schema_workspace { WsRoleApi }
import common.api

// ═══ Handler ═══
@['/assign_role_api'; post]
pub fn (app &WorkspaceCore) assign_role_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[AssignRoleApiReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := assign_role_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn assign_role_api_usecase(mut ctx Context, req AssignRoleApiReq) !AssignRoleApiResp {
	assign_role_api_domain(req)!
	return assign_role_api_repo(mut ctx, req)
}

// ═══ Domain ═══
fn assign_role_api_domain(req AssignRoleApiReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ═══ DTO ═══
pub struct AssignRoleApiReq {
	workspace_id string @[json: 'workspaceId']
	role_id      string @[json: 'roleId']
	api_ids      []string @[json: 'apiIds']
}

pub struct AssignRoleApiResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn assign_role_api_repo(mut ctx Context, req AssignRoleApiReq) !AssignRoleApiResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	sql db {
		delete from WsRoleApi where workspace_id == req.workspace_id && role_id == req.role_id
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to delete existing role API assignments: ${err}')
	}

	for api_id in req.api_ids {
		ra := WsRoleApi{
			workspace_id: req.workspace_id
			role_id: req.role_id
			api_id: api_id
		}
		sql db {
			insert ra into WsRoleApi
		} or {
			db.execute('ROLLBACK') or {}
			return error('Failed to insert role API assignment: ${err}')
		}
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }

	return AssignRoleApiResp{
		msg: 'Role API assigned'
	}
}
