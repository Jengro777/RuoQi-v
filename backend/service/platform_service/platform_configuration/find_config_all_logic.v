module platform_configuration

import veb
import log
import model { Context }
import model.schema_platform { PfConfig }
import common.api

// ═══ Handler ═══
@['/find_config_all'; post]
pub fn (app &PlatformConfiguration) find_config_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_config_all_usecase(mut ctx) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_config_all_usecase(mut ctx Context) ![]PfConfig {
	return find_config_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_config_all_repo(mut ctx Context) ![]PfConfig {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	configs := sql db {
		select from PfConfig where del_flag == 0
	} or { return error('Failed: ${err}') }
	return configs
}
