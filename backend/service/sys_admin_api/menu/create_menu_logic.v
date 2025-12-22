module menu

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_sys { SysMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Menu) create_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_menu_usecase(mut ctx Context, req CreateMenuReq) !CreateMenuResp {
	create_menu_domain(req)!
	return create_menu(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_menu_domain(req CreateMenuReq) ! {
	if req.name == '' {
		return error('Menu name is required')
	}
	if req.path == '' {
		return error('Menu path is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateMenuReq {
	parent_id             string @[json: 'parent_id']
	menu_level            u64    @[json: 'menuLevel']
	menu_type             u64    @[json: 'menuType']
	path                  string @[json: 'path']
	name                  string @[json: 'name']
	redirect              string @[json: 'redirect']
	component             string @[json: 'component']
	disabled              ?bool  @[json: 'disabled']
	service_name          string @[json: 'serviceName']
	permission            string @[json: 'permission']
	title                 string @[json: 'title']
	icon                  string @[json: 'icon']
	hide_menu             ?bool  @[json: 'hideMenu']
	hide_breadcrumb       ?bool  @[json: 'hideBreadcrumb']
	ignore_keep_alive     ?bool  @[json: 'ignoreKeepAlive']
	hide_tab              ?bool  @[json: 'hideTab']
	frame_src             string @[json: 'frameSrc']
	carry_param           ?bool  @[json: 'carryParam']
	hide_children_in_menu ?bool  @[json: 'hideChildrenInMenu']
	affix                 ?bool  @[json: 'affix']
	dynamic_level         u8     @[json: 'dynamicLevel']
	real_path             string @[json: 'realPath']
	sort                  u32    @[json: 'sort']
}

pub struct CreateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_menu(mut ctx Context, req CreateMenuReq) !CreateMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	time_now := time.now()
	menu := SysMenu{
		id:                    rand.uuid_v7()
		parent_id:             req.parent_id
		menu_level:            req.menu_level
		menu_type:             req.menu_type
		path:                  req.path
		name:                  req.name
		redirect:              req.redirect
		component:             req.component
		disabled:              if req.disabled or { false } { 1 } else { 0 } // true: 1 false: 0
		service_name:          req.service_name
		permission:            req.permission
		title:                 req.title
		icon:                  req.icon
		hide_menu:             if req.hide_menu or { false } { 1 } else { 0 }         // true: 1 false: 0
		hide_breadcrumb:       if req.hide_breadcrumb or { false } { 1 } else { 0 }   // true: 1 false: 0
		ignore_keep_alive:     if req.ignore_keep_alive or { false } { 1 } else { 0 } // true: 1 false: 0
		hide_tab:              if req.hide_tab or { false } { 1 } else { 0 }          // true: 1 false: 0
		frame_src:             req.frame_src
		carry_param:           if req.carry_param or { false } { 1 } else { 0 }           // true: 1 false: 0
		hide_children_in_menu: if req.hide_children_in_menu or { false } { 1 } else { 0 } // true: 1 false: 0
		affix:                 if req.affix or { false } { 1 } else { 0 }                 // true: 1 false: 0
		dynamic_level:         req.dynamic_level
		real_path:             req.real_path
		sort:                  req.sort
		created_at:            time_now
		updated_at:            time_now
	}

	sql db {
		insert menu into SysMenu
	} or { return error('Failed to create menu') }

	return CreateMenuResp{
		msg: 'Menu created successfully'
	}
}
