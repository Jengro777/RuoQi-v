module permission

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsRoleApi }
import common.api

// ═══ Handler ═══
@['/bind_role_api'; post]
pub fn (app &Permission) bind_role_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[BindRoleApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := bind_role_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn bind_role_api_usecase(mut ctx Context, req BindRoleApiReq) !PermResp {
	bind_role_api_domain(req)!
	bind_role_api_repo(mut ctx, req)!
	return PermResp{
		msg: 'Role-API binding saved'
	}
}

// ═══ Domain ═══
fn bind_role_api_domain(req BindRoleApiReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ═══ DTO ═══
pub struct BindRoleApiReq {
	workspace_id string   @[json: 'workspaceId']
	role_id      string   @[json: "roleId"]
	source_type  string   @[json: "sourceType"]
	source_id    string   @[json: "sourceId"]
	api_ids      []string @[json: 'apiIds']
}

pub struct PermResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn bind_role_api_repo(mut ctx Context, req BindRoleApiReq) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from WsRoleApi where workspace_id == req.workspace_id && role_id == req.role_id
	} or {}
	for api_id in req.api_ids {
		ra := WsRoleApi{
			workspace_id: req.workspace_id
			role_id:      req.role_id
			api_id:       api_id
			source_type:  ''
			source_id:    ''
		}
		sql db {
			insert ra into WsRoleApi
		}!
	}
}
