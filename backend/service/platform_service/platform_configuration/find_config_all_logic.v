module platform_configuration

import veb
import log
import structs { Context }
import structs.schema_platform { PfConfiguration }
import common.api

// ═══ Handler ═══
@['/find_config_all'; post]
pub fn (app &PlatformConfiguration) find_config_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_config_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_config_all_usecase(mut ctx Context) ![]PfConfiguration {
	return find_config_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_config_all_repo(mut ctx Context) ![]PfConfiguration {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	configs := sql db {
		select from PfConfiguration where del_flag == 0
	} or { return error('Failed: ${err}') }
	return configs
}
