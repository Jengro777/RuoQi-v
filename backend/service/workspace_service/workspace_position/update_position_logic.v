module workspace_position

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsPosition }
import common.api

// ═══ Handler ═══
@['/update_position'; post]
pub fn (app &WorkspacePosition) update_position_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdatePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_position_usecase(mut ctx Context, req UpdatePositionReq) !UpdatePositionResp {
	update_position_domain(req)!
	return update_position_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_position_domain(req UpdatePositionReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePositionReq {
	id          string  @[json: 'id']
	name        ?string @[json: 'name']
	code        ?string @[json: 'code']
	description ?string @[json: 'description']
	sort        ?u32    @[json: 'sort']
	status      ?u8     @[json: 'status']
}

pub struct UpdatePositionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_position_repo(mut ctx Context, req UpdatePositionReq) !UpdatePositionResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if name := req.name { name == name },
		if code := req.code { code == code },
		if description := req.description { description == description },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status }
	}
	sql db {
		dynamic update WsPosition set up_expr where id == req.id
	}!
	return UpdatePositionResp{
		msg: 'Position updated'
	}
}
