module menu

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_core { CoreMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/create'; post]
pub fn menu_create_handler(app &Menu, mut ctx Context) veb.Result {
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
pub fn create_menu_usecase(mut ctx Context, req CreateMenuReq) !CreateCoreMenuResp {
	// Domain 校验
	create_menu_domain(req)!

	// Repository 写入 DB
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
	id                    string    @[json: 'id']
	parent_id             string    @[json: 'parent_id']
	menu_level            u64       @[default: 0; json: 'menuLevel']
	menu_type             u64       @[default: 0; json: 'menuType']
	path                  string    @[json: 'path']
	name                  string    @[json: 'name']
	redirect              string    @[json: 'redirect']
	component             string    @[json: 'component']
	disabled              u8        @[default: 0; json: 'disabled']
	service_name          string    @[json: 'service_name']
	permission            string    @[json: 'permission']
	title                 string    @[json: 'title']
	icon                  string    @[json: 'icon']
	hide_menu             u8        @[default: 0; json: 'hideMenu']
	hide_breadcrumb       u8        @[default: 0; json: 'hideBreadcrumb']
	ignore_keep_alive     u8        @[default: 0; json: 'ignoreKeepAlive']
	hide_tab              u8        @[default: 0; json: 'hideTab']
	frame_src             string    @[json: 'frame_src']
	carry_param           u8        @[default: 0; json: 'carryParam']
	hide_children_in_menu u8        @[default: 0; json: 'hideChildrenInMenu']
	affix                 u8        @[default: 20; json: 'affix']
	dynamic_level         u8        @[default: 0; json: 'dynamicLevel']
	real_path             string    @[json: 'real_path']
	sort                  u32       @[default: 0; json: 'sort']
	source_type           string    @[json: 'source_type']
	source_id             string    @[json: 'source_id']
	created_at            time.Time @[json: 'created_at']
	updated_at            time.Time @[json: 'updated_at']
}

pub struct CreateCoreMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_menu_repo(mut ctx Context, req CreateMenuReq) !CreateCoreMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	menu := CoreMenu{
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
		source_type:           req.source_type
		source_id:             req.source_id
		created_at:            req.created_at
		updated_at:            req.updated_at
	}

	sql db {
		insert menu into CoreMenu
	} or { return error('Failed to insert menu: ${err}') }

	return CreateCoreMenuResp{
		msg: 'CoreMenu created successfully'
	}
}
