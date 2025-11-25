module menu

import veb
import log
import orm
import time
import x.json2 as json
import rand
import structs.schema_sys { SysMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Menu) menu_create_handler(mut ctx Context) veb.Result {
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
	return create_menu_repo(mut ctx, req)
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
	parent_id             string     @[json: 'parent_id']
	menu_level            u64        @[json: 'menu_level']
	menu_type             u64        @[json: 'menu_type']
	path                  string     @[json: 'path']
	name                  string     @[json: 'name']
	redirect              string     @[json: 'redirect']
	component             string     @[json: 'component']
	disabled              u8         @[json: 'disabled']
	service_name          string     @[json: 'service_name']
	permission            string     @[json: 'permission']
	title                 string     @[json: 'title']
	icon                  string     @[json: 'icon']
	hide_menu             u8         @[json: 'hide_menu']
	hide_breadcrumb       u8         @[json: 'hide_breadcrumb']
	ignore_keep_alive     u8         @[json: 'ignore_keep_alive']
	hide_tab              u8         @[json: 'hide_tab']
	frame_src             string     @[json: 'frame_src']
	carry_param           u8         @[json: 'carry_param']
	hide_children_in_menu u8         @[json: 'hide_children_in_menu']
	affix                 u8         @[json: 'affix']
	dynamic_level         u8         @[json: 'dynamic_level']
	real_path             string     @[json: 'real_path']
	sort                  u32        @[json: 'sort']
	created_at            ?time.Time @[json: 'created_at']
	updated_at            ?time.Time @[json: 'updated_at']
}

pub struct CreateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_menu_repo(mut ctx Context, req CreateMenuReq) !CreateMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysMenu](db)

	menu := SysMenu{
		id:                    rand.uuid_v7()
		parent_id:             req.parent_id
		menu_level:            req.menu_level
		menu_type:             req.menu_type
		path:                  req.path
		name:                  req.name
		redirect:              req.redirect
		component:             req.component
		disabled:              req.disabled
		service_name:          req.service_name
		permission:            req.permission
		title:                 req.title
		icon:                  req.icon
		hide_menu:             req.hide_menu
		hide_breadcrumb:       req.hide_breadcrumb
		ignore_keep_alive:     req.ignore_keep_alive
		hide_tab:              req.hide_tab
		frame_src:             req.frame_src
		carry_param:           req.carry_param
		hide_children_in_menu: req.hide_children_in_menu
		affix:                 req.affix
		dynamic_level:         req.dynamic_level
		real_path:             req.real_path
		sort:                  req.sort
		created_at:            req.created_at or { time.now() }
		updated_at:            req.updated_at or { time.now() }
	}

	q.insert(menu)!

	return CreateMenuResp{
		msg: 'Menu created successfully'
	}
}
