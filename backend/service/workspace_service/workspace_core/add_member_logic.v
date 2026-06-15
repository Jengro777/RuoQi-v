module workspace_core

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsMember }
import common.api

// ═══ Handler ═══
@['/add_member'; post]
pub fn (app &WorkspaceCore) add_member_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[AddMemberReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := add_member_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn add_member_usecase(mut ctx Context, req AddMemberReq) !AddMemberResp {
	add_member_domain(req)!
	return add_member_repo(mut ctx, req)
}

// ═══ Domain ═══
fn add_member_domain(req AddMemberReq) ! {
	if req.workspace_id == '' { return error('workspace_id is required') }
	if req.user_id == '' { return error('user_id is required') }
}

// ═══ DTO ═══
pub struct AddMemberReq {
	workspace_id string @[json: 'workspaceId']
	user_id      string @[json: 'userId']
	role_id      string @[json: 'roleId']
}

pub struct AddMemberResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn add_member_repo(mut ctx Context, req AddMemberReq) !AddMemberResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	m := WsMember{
		workspace_id: req.workspace_id
		user_id:      req.user_id
		role_id:      req.role_id
	}
	sql db {
		upsert m into WsMember
	} or { return error('Failed: ${err}') }
	return AddMemberResp{
		msg: 'Member added'
	}
}
