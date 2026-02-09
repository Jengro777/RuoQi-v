module menu

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_core { CoreMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/update'; post]
pub fn menu_update_handler(app &Menu, mut ctx Context) veb.Result {
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

	// Repository 更新数据库
	return update_menu_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_menu_domain(req UpdateMenuReq) ! {
	if req.id == '' {
		return error('id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
	if req.updated_at.unix() == 0 {
		return error('updated_at is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateMenuReq {
	id                    string    @[json: 'id']
	parent_id             u64       @[default: 0; json: 'parent_id']
	menu_level            u8        @[default: 0; json: 'menuLevel']
	menu_type             u8        @[default: 0; json: 'menuType']
	path                  string    @[json: 'path']
	name                  string    @[json: 'name']
	redirect              string    @[json: 'redirect']
	component             string    @[json: 'component']
	disabled              u8        @[json: 'disabled']
	service_name          string    @[json: 'serviceName']
	permission            string    @[json: 'permission']
	title                 string    @[json: 'title']
	icon                  string    @[json: 'icon']
	hide_menu             u8        @[json: 'hideMenu']
	hide_breadcrumb       u8        @[json: 'hideBreadcrumb']
	ignore_keep_alive     u8        @[json: 'ignoreKeepAlive']
	hide_tab              u8        @[json: 'hideTab']
	frame_src             string    @[json: 'frameSrc']
	carry_param           u8        @[json: 'carryParam']
	hide_children_in_menu u8        @[json: 'hideChildrenInMenu']
	affix                 u8        @[default: 20; json: 'affix']
	dynamic_level         u64       @[json: 'dynamicLevel']
	real_path             string    @[json: 'realPath']
	sort                  u64       @[json: 'sort']
	source_type           string    @[json: 'source_type']
	source_id             string    @[json: 'source_id']
	updated_at            time.Time @[json: 'updated_at']
}

pub struct UpdateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_menu_repo(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[CoreMenu](db)

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
		.set('updated_at = ?', req.updated_at)!
		.where('id = ?', req.id)!
		.update()!

	return UpdateMenuResp{
		msg: 'CoreMenu Updated Successfully'
	}
}
