module workspace_position

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsPosition }
import common.api

// ═══ Handler ═══
@['/create_position'; post]
pub fn (app &WorkspacePosition) create_position_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreatePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_position_usecase(mut ctx Context, req CreatePositionReq) !CreatePositionResp {
	create_position_domain(req)!
	return create_position_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_position_domain(req CreatePositionReq) ! {
	if req.name == '' {
		return error('name is required')
	}
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
}

// ═══ DTO ═══
pub struct CreatePositionReq {
	workspace_id string @[json: 'workspaceId']
	name         string @[json: 'name']
	code         string @[json: 'code']
	description  string @[json: 'description']
	sort         u32    @[json: 'sort']
}

pub struct CreatePositionResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_position_repo(mut ctx Context, req CreatePositionReq) !CreatePositionResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	p := WsPosition{
		id:           rand.uuid_v7()
		workspace_id: req.workspace_id
		name:         req.name
		code:         req.code
		description:  req.description
		sort:         req.sort
		status:       0
		created_at:   time.now()
		updated_at:   time.now()
	}
	sql db {
		insert p into WsPosition
	} or { return error('Failed: ${err}') }
	return CreatePositionResp{
		id:  p.id
		msg: 'Position created'
	}
}
