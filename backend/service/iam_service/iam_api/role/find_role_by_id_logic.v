module role

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_iam { IamRole }
import common.api

// ═══ Handler ═══
@['/find_role_by_id'; post]
pub fn (app &Role) find_role_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_role_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_role_by_id_usecase(mut ctx Context, req FindByIdReq) !IamRole {
	find_role_by_id_domain(req)!
	return find_role_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_role_by_id_domain(req FindByIdReq) ! {
	if req.id == '' {
		return error('role id is required')
	}
}

// ═══ DTO ═══
pub struct FindByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_role_by_id_repo(mut ctx Context, req FindByIdReq) !IamRole {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	roles := sql db {
		select from IamRole where id == req.id limit 1
	} or { return error('Failed: ${err}') }
	if roles.len == 0 { return error('role not found') }
	return roles[0]
}
