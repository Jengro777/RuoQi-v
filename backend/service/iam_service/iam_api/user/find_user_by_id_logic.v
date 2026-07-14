module user

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/find_user_by_id'; post]
pub fn (app &User) find_user_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_user_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_user_by_id_usecase(mut ctx Context, req FindByIdReq) !IamUser {
	find_user_by_id_domain(req)!
	return find_user_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_user_by_id_domain(req FindByIdReq) ! {
	if req.id == '' {
		return error('user id is required')
	}
}

// ═══ DTO ═══
pub struct FindByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_user_by_id_repo(mut ctx Context, req FindByIdReq) !IamUser {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	users := sql db {
		select from IamUser where id == req.id limit 1
	} or { return error('Failed: ${err}') }
	if users.len == 0 { return error('user not found') }
	return users[0]
}
