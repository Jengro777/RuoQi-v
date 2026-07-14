module workspace_core

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_workspace { WsMember }
import common.api

// ═══ Handler ═══
@['/remove_member'; post]
pub fn (app &WorkspaceCore) remove_member_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[RemoveMemberReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := remove_member_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn remove_member_usecase(mut ctx Context, req RemoveMemberReq) !RemoveMemberResp {
	remove_member_domain(req)!
	return remove_member_repo(mut ctx, req)
}

// ═══ Domain ═══
fn remove_member_domain(req RemoveMemberReq) ! {
	if req.workspace_id == '' { return error('workspace_id is required') }
	if req.user_id == '' { return error('user_id is required') }
}

// ═══ DTO ═══
pub struct RemoveMemberReq {
	workspace_id string @[json: 'workspaceId']
	user_id      string @[json: 'userId']
}

pub struct RemoveMemberResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn remove_member_repo(mut ctx Context, req RemoveMemberReq) !RemoveMemberResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from WsMember where workspace_id == req.workspace_id && user_id == req.user_id
	}!
	return RemoveMemberResp{
		msg: 'Member removed'
	}
}
