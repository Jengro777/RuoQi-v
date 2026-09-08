module platform_menu

import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfMenu }
import common.api

// ═══ Handler ═══
@['/update_menu'; post]
pub fn (app &PlatformMenu) update_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_menu_usecase(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	update_menu_domain(req)!
	return update_menu_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_menu_domain(req UpdateMenuReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateMenuReq {
	id         string @[json: 'id']
	parent_id  ?string @[json: 'parentId']
	menu_level ?u8 @[json: 'menuLevel']
	menu_type  ?u8 @[json: 'menuType']
	path       ?string @[json: 'path']
	name       ?string @[json: 'name']
	redirect   ?string @[json: 'redirect']
	component  ?string @[json: 'component']
	order_no   ?u32 @[json: 'orderNo']
	icon       ?string @[json: 'icon']
	title      ?string @[json: 'title']
	status     ?u8 @[json: 'status']
}

pub struct UpdateMenuResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_menu_repo(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr :=
		sql {
		}
	sql db {
		dynamic update PfMenu set up_expr where id == req.id
	}!
	return UpdateMenuResp{
		msg: 'Menu updated'
	}
}
