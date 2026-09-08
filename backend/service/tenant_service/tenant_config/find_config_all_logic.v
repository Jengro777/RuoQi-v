module tenant_config

import veb
import log
import model { Context }
import model.schema_tenant { TnConfig }
import common.api as capi

// ═══ Handler ═══
@['/find_config_all'; get]
pub fn (app &TenantConfig) find_config_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_config_all_usecase(mut ctx) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_config_all_usecase(mut ctx Context) ![]TnConfig {
	return find_config_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_config_all_repo(mut ctx Context) ![]TnConfig {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	items := sql db {
		select from TnConfig where del_flag == 0
	} or { return error('Failed to query configs: ${err}') }
	return items
}
