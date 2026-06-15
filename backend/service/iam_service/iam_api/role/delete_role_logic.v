module role

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamRole }
import common.api

// ═══ Handler ═══
@['/delete_role'; post]
pub fn (app &Role) delete_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_role_usecase(mut ctx Context, req DeleteRoleReq) !RoleResp {
	delete_role_domain(req)!
	delete_role_repo(mut ctx, req)!
	return RoleResp{
		msg: 'Role deleted'
	}
}

// ═══ Domain ═══
fn delete_role_domain(req DeleteRoleReq) ! {
	if req.id == '' {
		return error('role id is required')
	}
}

// ═══ DTO ═══
pub struct DeleteRoleReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn delete_role_repo(mut ctx Context, req DeleteRoleReq) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from IamRole where id == req.id
	}!
}
