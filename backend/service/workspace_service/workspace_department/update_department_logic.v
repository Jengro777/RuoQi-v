module workspace_department

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsDepartment }
import common.api

// ═══ Handler ═══
@['/update_department'; post]
pub fn (app &WorkspaceDepartment) update_department_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_department_usecase(mut ctx Context, req UpdateDepartmentReq) !UpdateDepartmentResp {
	update_department_domain(req)!
	return update_department_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_department_domain(req UpdateDepartmentReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateDepartmentReq {
	id          string  @[json: 'id']
	parent_id   ?string @[json: 'parentId']
	name        ?string @[json: 'name']
	code        ?string @[json: 'code']
	description ?string @[json: 'description']
	sort        ?u32    @[json: 'sort']
	status      ?u8     @[json: 'status']
}

pub struct UpdateDepartmentResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_department_repo(mut ctx Context, req UpdateDepartmentReq) !UpdateDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if parent_id := req.parent_id { parent_id == parent_id },
		if name := req.name { name == name },
		if code := req.code { code == code },
		if description := req.description { description == description },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status }
	}
	sql db {
		dynamic update WsDepartment set up_expr where id == req.id
	}!
	return UpdateDepartmentResp{
		msg: 'Department updated'
	}
}
