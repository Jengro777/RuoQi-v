module platform_menu

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfMenu }
import common.api

// ═══ Handler ═══
@['/create_menu'; post]
pub fn (app &PlatformMenu) create_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_menu_usecase(mut ctx Context, req CreateMenuReq) !CreateMenuResp {
	create_menu_domain(req)!
	return create_menu_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_menu_domain(req CreateMenuReq) ! {
	if req.name == '' { return error('name is required') }
}

// ═══ DTO ═══
pub struct CreateMenuReq {
	parent_id  string @[json: 'parentId']
	menu_level u8     @[json: 'menuLevel']
	menu_type  u8     @[json: 'menuType']
	path       string @[json: 'path']
	name       string @[json: 'name']
	redirect   string @[json: 'redirect']
	component  string @[json: 'component']
	order_no   u32    @[json: 'orderNo']
	icon       string @[json: 'icon']
	title      string @[json: 'title']
}

pub struct CreateMenuResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_menu_repo(mut ctx Context, req CreateMenuReq) !CreateMenuResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	menu := PfMenu{
		id:         rand.uuid_v7()
		parent_id:  req.parent_id
		menu_level: req.menu_level
		menu_type:  req.menu_type
		path:       req.path
		name:       req.name
		redirect:   req.redirect
		component:  req.component
		order_no:   req.order_no
		icon:       req.icon
		title:      req.title
		status:     0
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert menu into PfMenu
	} or { return error('Failed: ${err}') }
	return CreateMenuResp{
		id:  menu.id
		msg: 'Menu created'
	}
}
