module platform_menu

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfMenu }
import common.api

// ═══ Handler ═══
@['/find_menu_by_id'; post]
pub fn (app &PlatformMenu) find_menu_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindMenuByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_menu_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_menu_by_id_usecase(mut ctx Context, req FindMenuByIdReq) !PfMenu {
	find_menu_by_id_domain(req)!
	return find_menu_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_menu_by_id_domain(req FindMenuByIdReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct FindMenuByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_menu_by_id_repo(mut ctx Context, req FindMenuByIdReq) !PfMenu {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	menus := sql db {
		select from PfMenu where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed: ${err}') }
	if menus.len == 0 { return error('Menu not found') }
	return menus[0]
}
