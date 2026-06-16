module user

import veb
import log
import structs { Context }
import structs.schema_iam { IamUserRole }
import common.api

// ═══ Handler ═══
@['/perm'; get; post]
pub fn (app &User) find_user_perm_code_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_user_perm_code_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_user_perm_code_usecase(mut ctx Context) ![]string {
	find_user_perm_code_domain(mut ctx)!
	return find_user_perm_code_repo(mut ctx)
}

// ═══ Domain ═══
fn find_user_perm_code_domain(mut ctx Context) ! {
	if ctx.svc_iam.user_id == '' {
		return error('user not authenticated')
	}
}

// ═══ Repository ═══
fn find_user_perm_code_repo(mut ctx Context) ![]string {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	roles := sql db {
		select from IamUserRole where user_id == ctx.svc_iam.user_id
	} or { return error('Failed: ${err}') }
	return roles.map(it.role_id)
}
