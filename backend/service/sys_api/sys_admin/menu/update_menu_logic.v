module menu

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/update'; post]
pub fn(app &Menu)update_menu_handler(mut ctx Context) veb.Result {
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
	// Domain 校验
	update_menu_domain(req)!

	// Repository 执行更新
	return update_menu_repo(mut ctx, req)
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
	dynamic_level         u64        @[json: 'dynamic_level']
	real_path             string     @[json: 'real_path']
	sort                  u64        @[json: 'sort']
	updated_at            ?time.Time @[json: 'updated_at']
}

pub struct UpdateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_menu_repo(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysMenu](db)

	q.set('parent_id = ?', req.parent_id)!
		.set('menu_level = ?', req.menu_level)!
		.set('menu_type = ?', req.menu_type)!
		.set('path = ?', req.path)!
		.set('name = ?', req.name)!
		.set('redirect = ?', req.redirect)!
		.set('component = ?', req.component)!
		.set('disabled = ?', req.disabled)!
		.set('service_name = ?', req.service_name)!
		.set('permission = ?', req.permission)!
		.set('title = ?', req.title)!
		.set('icon = ?', req.icon)!
		.set('hide_menu = ?', req.hide_menu)!
		.set('hide_breadcrumb = ?', req.hide_breadcrumb)!
		.set('ignore_keep_alive = ?', req.ignore_keep_alive)!
		.set('hide_tab = ?', req.hide_tab)!
		.set('frame_src = ?', req.frame_src)!
		.set('carry_param = ?', req.carry_param)!
		.set('hide_children_in_menu = ?', req.hide_children_in_menu)!
		.set('affix = ?', req.affix)!
		.set('dynamic_level = ?', req.dynamic_level)!
		.set('real_path = ?', req.real_path)!
		.set('sort = ?', req.sort)!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateMenuResp{
		msg: 'Menu updated successfully'
	}
}
