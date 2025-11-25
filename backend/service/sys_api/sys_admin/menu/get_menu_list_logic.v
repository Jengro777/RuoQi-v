module menu

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/list'; post]
pub fn (app &Menu) menu_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[MenuListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := menu_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn menu_list_usecase(mut ctx Context, req MenuListReq) !MenuListResp {
	menu_list_domain(req)!
	return menu_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn menu_list_domain(req MenuListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct MenuListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'page_size']
	name      string @[json: 'name']
}

pub struct MenuData {
	id                    string @[json: 'id']
	parent_id             string @[json: 'parentId']
	menu_level            string @[json: 'menuLevel']
	menu_type             string @[json: 'menuType']
	path                  string @[json: 'path']
	name                  string @[json: 'name']
	redirect              string @[json: 'redirect']
	component             string @[json: 'component']
	disabled              int    @[json: 'disabled']
	service_name          string @[json: 'serviceName']
	permission            string @[json: 'permission']
	title                 string @[json: 'title']
	icon                  string @[json: 'icon']
	hide_menu             int    @[json: 'hideMenu']
	hide_breadcrumb       int    @[json: 'hideBreadcrumb']
	ignore_keep_alive     int    @[json: 'ignoreKeepAlive']
	hide_tab              int    @[json: 'hideTab']
	frame_src             string @[json: 'frameSrc']
	carry_param           int    @[json: 'carryParam']
	hide_children_in_menu int    @[json: 'hideChildrenInMenu']
	affix                 int    @[json: 'affix']
	dynamic_level         int    @[json: 'dynamicLevel']
	real_path             string @[json: 'realPath']
	sort                  int    @[json: 'sort']
	created_at            string @[json: 'createdAt']
	updated_at            string @[json: 'updatedAt']
	deleted_at            string @[json: 'deletedAt']
}

pub struct MenuListResp {
	total int
	data  []MenuData
}

// ----------------- Repository 层 -----------------
fn menu_list_repo(mut ctx Context, req MenuListReq) !MenuListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	offset_num := (req.page - 1) * req.page_size
	mut sys_menu := orm.new_query[SysMenu](db)

	// 条件查询
	mut query := sys_menu.select()!
	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	// 总数统计
	mut count := sql db {
		select count from SysMenu
	}!

	// 构造返回数据
	mut datalist := []MenuData{}
	for row in result {
		datalist << MenuData{
			id:                    row.id
			parent_id:             row.parent_id or { '' }
			menu_level:            row.menu_level.str()
			menu_type:             row.menu_type.str()
			path:                  row.path or { '' }
			name:                  row.name.str()
			redirect:              row.redirect or { '' }
			component:             row.component or { '' }
			disabled:              int(row.disabled or { 0 })
			service_name:          row.service_name or { '' }
			permission:            row.permission or { '' }
			title:                 row.title.str()
			icon:                  row.icon.str()
			hide_menu:             int(row.hide_menu or { 0 })
			hide_breadcrumb:       int(row.hide_breadcrumb or { 0 })
			ignore_keep_alive:     int(row.ignore_keep_alive or { 0 })
			hide_tab:              int(row.hide_tab or { 0 })
			frame_src:             row.frame_src or { '' }
			carry_param:           int(row.carry_param or { 0 })
			hide_children_in_menu: int(row.hide_children_in_menu or { 0 })
			affix:                 int(row.affix or { 0 })
			dynamic_level:         int(row.dynamic_level or { 20 })
			real_path:             row.real_path or { '' }
			sort:                  int(row.sort)
			created_at:            row.created_at.format_ss()
			updated_at:            row.updated_at.format_ss()
			deleted_at:            (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return MenuListResp{
		total: count
		data:  datalist
	}
}
