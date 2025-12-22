module menu

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_core { CoreMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/list'; post]
pub fn menu_list_handler(app &Menu, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetMenuListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_menu_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn get_menu_list_usecase(mut ctx Context, req GetMenuListReq) !GetMenuListResp {
	get_menu_list_domain(req)!
	return find_menu_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_menu_list_domain(req GetMenuListReq) ! {
	if req.page <= 0 {
		return error('page must be positive integer')
	}
	if req.page_size <= 0 {
		return error('page_size must be positive integer')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetMenuListReq {
	page      int    @[default: 1; json: 'page']
	page_size int    @[default: 10; json: 'page_size']
	name      string @[json: 'name']
}

pub struct GetMenuListResp {
	total int
	data  []GetMenuList
}

pub struct GetMenuList {
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
	dynamic_level         u32        @[default: 20; json: 'dynamic_level']
	real_path             string     @[json: 'real_path']
	sort                  u32        @[json: 'sort']
	source_type           string     @[json: 'source_type']
	source_id             string     @[json: 'source_id']
	created_at            ?time.Time @[json: 'created_at']
	updated_at            ?time.Time @[json: 'updated_at']
	deleted_at            ?time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn find_menu_list_repo(mut ctx Context, req GetMenuListReq) !GetMenuListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	offset_num := (req.page - 1) * req.page_size

	mut q := orm.new_query[CoreMenu](db)
	mut query := q.select()!

	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	// 总数统计
	mut count := sql db {
		select count from CoreMenu
	}!

	mut datalist := []GetMenuList{}

	for row in result {
		datalist << GetMenuList{
			id:                    row.id
			parent_id:             row.parent_id or { '' }
			menu_level:            row.menu_level
			menu_type:             row.menu_type
			path:                  row.path or { '' }
			name:                  row.name
			redirect:              row.redirect or { '' }
			component:             row.component or { '' }
			disabled:              row.disabled or { 0 }
			service_name:          row.service_name
			permission:            row.permission or { '' }
			title:                 row.title
			icon:                  row.icon
			hide_menu:             row.hide_menu or { 0 }
			hide_breadcrumb:       row.hide_breadcrumb or { 0 }
			ignore_keep_alive:     row.ignore_keep_alive or { 0 }
			hide_tab:              row.hide_tab or { 0 }
			frame_src:             row.frame_src or { '' }
			carry_param:           row.carry_param or { 0 }
			hide_children_in_menu: row.hide_children_in_menu or { 0 }
			affix:                 row.affix or { 0 }
			dynamic_level:         row.dynamic_level or { 20 }
			real_path:             row.real_path or { '' }
			sort:                  row.sort
			source_type:           row.source_type
			source_id:             row.source_id
			created_at:            row.created_at
			updated_at:            row.updated_at
			deleted_at:            row.deleted_at
		}
	}

	return GetMenuListResp{
		total: count
		data:  datalist
	}
}
