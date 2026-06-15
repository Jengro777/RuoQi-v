module platform_api

import veb
import log
import structs { Context }
import structs.schema_platform { PfApi }
import common.api as capi

// ═══ Handler ═══
@['/find_api_all'; post]
pub fn (app &PlatformApi) find_api_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_api_all_usecase(mut ctx) or { return ctx.json(capi.json_error_500(err.msg())) }
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_api_all_usecase(mut ctx Context) ![]PfApi {
	return find_api_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_api_all_repo(mut ctx Context) ![]PfApi {
	sr := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(sr.conn) or { log.warn('Failed to release conn: ${err}') } }
	apis := sql sr.db {
		select from PfApi where del_flag == 0
	} or { return error('Failed: ${err}') }
	return apis
}
