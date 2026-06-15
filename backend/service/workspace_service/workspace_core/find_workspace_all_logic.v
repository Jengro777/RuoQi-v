module workspace_core

import veb
import log
import structs { Context }
import structs.schema_workspace { WsWorkspace }
import common.api

// ═══ Handler ═══
@['/find_workspace_all'; post]
pub fn (app &WorkspaceCore) find_workspace_all_handler(mut ctx Context) veb.Result {
	result := find_workspace_all_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_workspace_all_usecase(mut ctx Context) ![]WsWorkspace {
	return find_workspace_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_workspace_all_repo(mut ctx Context) ![]WsWorkspace {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	return sql db {
		select from WsWorkspace where del_flag == 0
	} or { return error('Failed: ${err}') }
}
