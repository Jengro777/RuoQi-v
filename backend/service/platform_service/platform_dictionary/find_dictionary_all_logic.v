module platform_dictionary

import veb
import log
import structs { Context }
import structs.schema_platform { PfDictionary }
import common.api

// ═══ Handler ═══
@['/find_dictionary_all'; post]
pub fn (app &PlatformDictionary) find_dictionary_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_dictionary_all_usecase(mut ctx) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_dictionary_all_usecase(mut ctx Context) ![]PfDictionary {
	return find_dictionary_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_dictionary_all_repo(mut ctx Context) ![]PfDictionary {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	dicts := sql db {
		select from PfDictionary where del_flag == 0
	} or { return error('Failed: ${err}') }
	return dicts
}
