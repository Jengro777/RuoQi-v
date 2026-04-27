module role

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Role) update_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_role_usecase(mut ctx Context, req UpdateRoleReq) !UpdateRoleResp {
	// 参数校验
	update_role_domain(req)!

	// 执行数据库更新
	return update_role(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_role_domain(req UpdateRoleReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateRoleReq {
	id              string  @[json: 'id']
	status          ?u8     @[json: 'status']
	name            ?string @[json: 'name']
	code            ?string @[json: 'code']
	default_router  ?string @[json: 'defaultRouter']
	remark          ?string @[json: 'remark']
	sort            ?u64    @[json: 'sort']
	data_scope      ?u8     @[json: 'dataScope']
	custom_dept_ids ?string @[json: 'customDeptIds']
}

pub struct UpdateRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_role(mut ctx Context, req UpdateRoleReq) !UpdateRoleResp {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if status := req.status { status == status },
		if name := req.name { name == name },
		if code := req.code { code == code },
		if default_router := req.default_router { default_router == default_router },
		if remark := req.remark { remark == remark },
		if sort := req.sort { sort == sort },
		if data_scope := req.data_scope { data_scope == data_scope },
		if custom_dept_ids := req.custom_dept_ids { custom_dept_ids == custom_dept_ids },
		updated_at == time.now()
	}

	sql db {
		dynamic update SysRole set up_expr where id == req.id
	}!

	return UpdateRoleResp{
		msg: 'Role updated successfully'
	}
}
