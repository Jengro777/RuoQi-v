module menu

import veb
import log
// import orm
import time
import x.json2 as json
import structs.schema_sys { SysMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Menu) update_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_menu_usecase(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	update_menu_domain(req)!

	return update_menu(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_menu_domain(req UpdateMenuReq) ! {
	if req.id == '' {
		return error('menu id is required')
	}
	if req.name == '' {
		return error('menu name is required')
	}
	if req.path == '' {
		return error('menu path is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateMenuReq {
	id                    string     @[json: 'id']
	parent_id             string     @[json: 'parentId']
	menu_level            u64        @[json: 'menuLevel']
	menu_type             u64        @[json: 'menuType']
	path                  string     @[json: 'path']
	name                  string     @[json: 'name']
	redirect              string     @[json: 'redirect']
	component             string     @[json: 'component']
	disabled              ?bool      @[json: 'disabled']
	service_name          string     @[json: 'serviceName']
	permission            string     @[json: 'permission']
	title                 string     @[json: 'title']
	icon                  string     @[json: 'icon']
	hide_menu             ?bool      @[json: 'hideMenu']
	hide_breadcrumb       ?bool      @[json: 'hideBreadcrumb']
	ignore_keep_alive     ?bool      @[json: 'ignoreKeepAlive']
	hide_tab              ?bool      @[json: 'hideTab']
	frame_src             string     @[json: 'frameSrc']
	carry_param           ?bool      @[json: 'carryParam']
	hide_children_in_menu ?bool      @[json: 'hideChildrenInMenu']
	affix                 ?bool      @[json: 'affix']
	dynamic_level         u32        @[json: 'dynamicLevel']
	real_path             string     @[json: 'realPath']
	sort                  u32        @[json: 'sort']
	updated_at            ?time.Time @[json: 'updatedAt']
}

pub struct UpdateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_menu(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update SysMenu set parent_id = req.parent_id, menu_level = req.menu_level, menu_type = req.menu_type,
		path = req.path, name = req.name, redirect = req.redirect, component = req.component,
		disabled = fn [req] () u8 {
		return if req.disabled or { false } { u8(1) } else { u8(0) }
	}(), service_name = req.service_name, permission = req.permission, title = req.title,
		icon = req.icon, hide_menu = fn [req] () u8 {
		return if req.hide_menu or { false } { u8(1) } else { u8(0) }
	}(), hide_breadcrumb = fn [req] () u8 {
		return if req.hide_breadcrumb or { false } { u8(1) } else { u8(0) }
	}(), ignore_keep_alive = fn [req] () u8 {
		return if req.ignore_keep_alive or { false } { u8(1) } else { u8(0) }
	}(), hide_tab = fn [req] () u8 {
		return if req.hide_tab or { false } { u8(1) } else { u8(0) }
	}(), frame_src = req.frame_src, carry_param = fn [req] () u8 {
		return if req.carry_param or { false } { u8(1) } else { u8(0) }
	}(), hide_children_in_menu = fn [req] () u8 {
		return if req.hide_children_in_menu or { false } { u8(1) } else { u8(0) }
	}(), affix = fn [req] () u8 {
		return if req.affix or { false } { u8(1) } else { u8(0) }
	}(), dynamic_level = req.dynamic_level, real_path = req.real_path, sort = req.sort,
		updated_at = req.updated_at or { time.now() }.format_ss() where id == req.id
	} or { return error('Failed to update menu') }

	return UpdateMenuResp{
		msg: 'Menu updated successfully'
	}
}

// fn update_menu(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
// 	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
// 	defer {
// 		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
// 	}

// 	mut q := orm.new_query[SysMenu](db)

// 	q.set('parent_id         = ? ', req.parent_id)!
// 		.set('parent_id             =?', req.parent_id)!
// 		.set('menu_level            =?', req.menu_level)!
// 		.set('menu_type             =?', req.menu_type)!
// 		.set('path                  =?', req.path)!
// 		.set('name                  =?', req.name)!
// 		.set('redirect              =?', req.redirect)!
// 		.set('component             =?', req.component)!
// 		.set('disabled              =?', if req.disabled or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('service_name          =?', req.service_name)!
// 		.set('permission            =?', req.permission)!
// 		.set('title                 =?', req.title)!
// 		.set('icon                  =?', req.icon)!
// 		.set('hide_menu             =?', if req.hide_menu or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('hide_breadcrumb       =?', if req.hide_breadcrumb or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('ignore_keep_alive     =?', if req.ignore_keep_alive or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('hide_tab              =?', if req.hide_tab or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('frame_src             =?', req.frame_src)!
// 		.set('carry_param           =?', if req.carry_param or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('hide_children_in_menu =?', if req.hide_children_in_menu or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('affix                 =?', if req.affix or { false } { 1 } else { 0 })! // true: 1 false: 0
// 		.set('dynamic_level         =?', req.dynamic_level)!
// 		.set('real_path             =?', req.real_path)!
// 		.set('sort                  =?', req.sort)!
// 		.set('updated_at            =?', time.now())!
// 		.where('id = ?', req.id)!
// 		.update()!

// 	return UpdateMenuResp{
// 		msg: 'Menu updated successfully'
// 	}
// }
