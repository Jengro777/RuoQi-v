module platform_menu

import veb
import log
import structs { Context }
import structs.schema_platform { PfMenu }
import common.api

// ═══ Handler ═══
@['/find_menu_all'; post]
pub fn (app &PlatformMenu) find_menu_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_menu_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_menu_all_usecase(mut ctx Context) ![]PfMenu {
	return find_menu_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_menu_all_repo(mut ctx Context) ![]PfMenu {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	menus := sql db {
		select from PfMenu where del_flag == 0 order by order_no
	} or { return error('Failed: ${err}') }
	return menus
}
