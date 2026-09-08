module workspace_core

import veb
import log
import json2 as json
import model { Context }
import model.schema_workspace { WsRoleMenu }
import common.api

// ═══ Handler ═══
@['/assign_role_menu'; post]
pub fn (app &WorkspaceCore) assign_role_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[AssignRoleMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := assign_role_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn assign_role_menu_usecase(mut ctx Context, req AssignRoleMenuReq) !AssignRoleMenuResp {
	assign_role_menu_domain(req)!
	return assign_role_menu_repo(mut ctx, req)
}

// ═══ Domain ═══
fn assign_role_menu_domain(req AssignRoleMenuReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ═══ DTO ═══
pub struct AssignRoleMenuReq {
	workspace_id string @[json: 'workspaceId']
	role_id      string @[json: 'roleId']
	menu_ids     []string @[json: 'menuIds']
}

pub struct AssignRoleMenuResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn assign_role_menu_repo(mut ctx Context, req AssignRoleMenuReq) !AssignRoleMenuResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	sql db {
		delete from WsRoleMenu where workspace_id == req.workspace_id && role_id == req.role_id
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to delete existing role menu assignments: ${err}')
	}

	for menu_id in req.menu_ids {
		rm := WsRoleMenu{
			workspace_id: req.workspace_id
			role_id: req.role_id
			menu_id: menu_id
		}
		sql db {
			insert rm into WsRoleMenu
		} or {
			db.execute('ROLLBACK') or {}
			return error('Failed to insert role menu assignment: ${err}')
		}
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }

	return AssignRoleMenuResp{
		msg: 'Role Menu assigned'
	}
}
