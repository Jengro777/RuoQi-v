module role

import veb
import log
import x.json2 as json
import structs.schema_core { CoreRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role/delete'; post]
pub fn (app &Role) delete_tenantrole_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteTenantRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_tenantrole_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_tenantrole_usecase(mut ctx Context, req DeleteTenantRoleReq) !DeleteTenantRoleResp {
	// 参数校验
	delete_tenantrole_domain(req)!

	// 执行删除
	return delete_tenantrole_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_tenantrole_domain(req DeleteTenantRoleReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteTenantRoleReq {
	role_id string @[json: 'role_id']
}

pub struct DeleteTenantRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_tenantrole_repo(mut ctx Context, req DeleteTenantRoleReq) !DeleteTenantRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	update_expr := {
		del_flag == 1
	}
	sql db {
		dynamic update CoreRole set update_expr where id == req.role_id
	} or { return error('Failed to execute SQL query: ${err}') }

	return DeleteTenantRoleResp{
		msg: 'Delete Tenant Role Successfully'
	}
}
