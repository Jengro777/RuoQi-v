module role

import veb
import log
import time
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamRole }
import common.api

// ═══ Handler ═══
@['/update_role'; post]
pub fn (app &Role) update_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_role_usecase(mut ctx Context, req UpdateRoleReq) !RoleResp {
	update_role_domain(req)!
	update_role_repo(mut ctx, req)!
	return RoleResp{
		msg: 'Role updated'
	}
}

// ═══ Domain ═══
fn update_role_domain(req UpdateRoleReq) ! {
	if req.id == '' {
		return error('role id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateRoleReq {
	id     string @[json: 'id']
	name   string @[json: 'name']
	code   string @[json: 'code']
	remark string @[json: 'remark']
	sort   u32    @[json: 'sort']
	status u8     @[json: 'status']
}

// ═══ Repository ═══
fn update_role_repo(mut ctx Context, req UpdateRoleReq) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamRole set name = req.name, code = req.code, remark = req.remark, sort = req.sort,
		status = req.status, updated_at = time.now() where id == req.id
	}!
}
