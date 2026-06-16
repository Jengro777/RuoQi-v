module role

import veb
import log
import structs { Context }
import structs.schema_iam { IamRole }
import common.api

// ═══ Handler ═══
@['/find_role_all'; post]
pub fn (app &Role) find_role_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_role_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_role_all_usecase(mut ctx Context) ![]IamRole {
	return find_role_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_role_all_repo(mut ctx Context) ![]IamRole {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	roles := sql db {
		select from IamRole
	} or { return error('Failed: ${err}') }
	return roles
}
