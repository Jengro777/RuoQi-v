module role

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role/update'; post]
pub fn (app &Role) update_tenantrole_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateTenantRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_tenantrole_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_tenantrole_usecase(mut ctx Context, req UpdateTenantRoleReq) !UpdateTenantRoleResp {
	// Domain 校验层
	update_tenantrole_domain(req)!

	// Repository 写入数据库
	return update_tenantrole_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_tenantrole_domain(req UpdateTenantRoleReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
	if req.tenant_id == '' {
		return error('tenant_id is required')
	}
	// 其他字段根据需要可以加校验
}

// ----------------- DTO 层 -----------------
pub struct UpdateTenantRoleReq {
	role_id        string     @[json: 'role_id']
	tenant_id      string     @[json: 'tenant_id']
	status         ?u8        @[default: 0; json: 'status']
	name           ?string    @[json: 'name']
	default_router ?string    @[json: 'default_router']
	remark         ?string    @[json: 'remark']
	sort           ?u64       @[json: 'sort']
	updated_at     ?time.Time @[json: 'updated_at']
}

pub struct UpdateTenantRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_tenantrole_repo(mut ctx Context, req UpdateTenantRoleReq) !UpdateTenantRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	up_expr := {
		if status := req.status { status == status },
		if name := req.name { name == name },
		if default_router := req.default_router { default_router == default_router },
		if remark := req.remark { remark == remark },
		if sort := req.sort { sort == sort },
		updated_at == time.now()
	}

	sql db {
		dynamic update CoreRole set up_expr where {
		id == req.role_id,
		tenant_id == req.tenant_id
	}
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateTenantRoleResp{
		msg: 'Update Tenant Role successfully'
	}
}
