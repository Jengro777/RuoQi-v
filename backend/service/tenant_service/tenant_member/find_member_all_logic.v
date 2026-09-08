module tenant_member

import veb
import log
import model { Context }
import model.schema_tenant { TnMember }
import common.api as capi

// ═══ Handler ═══
@['/find_member_all'; get]
pub fn (app &TenantMember) find_member_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_member_all_usecase(mut ctx) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_member_all_usecase(mut ctx Context) ![]TnMember {
	return find_member_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_member_all_repo(mut ctx Context) ![]TnMember {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	items := sql db {
		select from TnMember where del_flag == 0
	} or { return error('Failed to query members: ${err}') }
	return items
}
