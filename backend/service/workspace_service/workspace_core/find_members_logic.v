module workspace_core

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsMember }
import common.api

// ═══ Handler ═══
@['/find_members'; post]
pub fn (app &WorkspaceCore) find_members_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindMembersReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_members_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_members_usecase(mut ctx Context, req FindMembersReq) ![]WsMember {
	find_members_domain(req)!
	return find_members_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_members_domain(req FindMembersReq) ! {
	if req.workspace_id == '' { return error('workspace_id is required') }
}

// ═══ DTO ═══
pub struct FindMembersReq {
	workspace_id string @[json: 'workspaceId']
}

// ═══ Repository ═══
fn find_members_repo(mut ctx Context, req FindMembersReq) ![]WsMember {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	return sql db {
		select from WsMember where workspace_id == req.workspace_id
	} or { return error('Failed: ${err}') }
}
