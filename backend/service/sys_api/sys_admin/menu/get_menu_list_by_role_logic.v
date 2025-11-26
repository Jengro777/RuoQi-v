module menu

import veb
import log
import time
import orm
import structs.schema_sys { SysMenu, SysRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role/list'; get]
pub fn (app &Menu) role_menu_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := role_menu_list_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn role_menu_list_usecase(mut ctx Context) !RoleMenuListResp {
	role_menu_list_domain()!
	return role_menu_list_repo(mut ctx)
}

// ----------------- Domain 层 -----------------
fn role_menu_list_domain() ! {
}

// ----------------- DTO 层 -----------------
pub struct RoleMenuListReq {
	// role_id string @[json: 'role_id']
}

pub struct MenuDataList {
	id                    string  @[json: 'id']
	parent_id             string  @[json: 'parent_id']
	menu_level            string  @[json: 'menu_level']
	menu_type             string  @[json: 'menu_type']
	path                  string  @[json: 'path']
	name                  string  @[json: 'name']
	redirect              string  @[json: 'redirect']
	component             string  @[json: 'component']
	disabled              int     @[json: 'disabled']
	service_name          string  @[json: 'service_name']
	permission            string  @[json: 'permission']
	title                 string  @[json: 'title']
	icon                  string  @[json: 'icon']
	hide_menu             int     @[json: 'hide_menu']
	hide_breadcrumb       int     @[json: 'hide_breadcrumb']
	ignore_keep_alive     int     @[json: 'ignore_keep_alive']
	hide_tab              int     @[json: 'hide_tab']
	frame_src             string  @[json: 'frame_src']
	carry_param           int     @[json: 'carry_param']
	hide_children_in_menu int     @[json: 'hide_children_in_menu']
	affix                 int     @[json: 'affix']
	dynamic_level         int     @[json: 'dynamic_level']
	real_path             string  @[json: 'real_path']
	sort                  int     @[json: 'sort']
	created_at            string  @[json: 'createdAt']
	updated_at            string  @[json: 'updatedAt']
	deleted_at            ?string @[json: 'deletedAt']
}

pub struct RoleMenuListResp {
	total int            @[json: 'total']
	data  []MenuDataList @[json: 'data']
}

// ----------------- Repository 层 -----------------
fn role_menu_list_repo(mut ctx Context) !RoleMenuListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	mut q_role_menu := orm.new_query[SysRoleMenu](db)
	mut query_menus := q_role_menu.select('menu_id')!
	query_menus = query_menus.where('role_id = ?', '00000000-0000-0000-0000-000000000001')!

	menu_id_arr := query_menus.query()!

	mut menu_ids := []orm.Primitive{}
	for item in menu_id_arr {
		menu_ids << item.menu_id
	}
	if menu_ids.len == 0 {
		return RoleMenuListResp{
			total: 0
			data:  []
		}
	}

	mut q_menu := orm.new_query[SysMenu](db)
	query := q_menu.select()!.where('id IN ?', menu_ids)!
	total_count := query.count()!
	result := query.query()!

	mut datalist := []MenuDataList{}
	for row in result {
		datalist << MenuDataList{
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
			deleted_at:            row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return RoleMenuListResp{
		total: total_count
		data:  datalist
	}
}
