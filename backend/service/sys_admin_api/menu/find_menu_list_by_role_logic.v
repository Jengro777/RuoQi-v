/*
 * @Author: RuoQi
 * @Date: 2025-11-28
 * @Description:  login 后菜单列表
 */

module menu

import veb
import log
import structs.schema_sys { SysMenu, SysRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role/list'; get]
pub fn (app &Menu) find_role_menu_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := role_menu_list_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	ctx.res.header.add_custom('Content-Type', 'application/json; charset=utf-8') or {
		// 处理错误
		log.error('Failed to set header: ${err}')
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn role_menu_list_usecase(mut ctx Context) !RoleMenuListResp {
	role_ids := ctx.svc_sys.role_ids
	role_menu_list_domain(role_ids)!

	return find_menuids_by_roleids(mut ctx, role_ids)
}

// ----------------- Domain 层 -----------------
fn role_menu_list_domain(roleids []string) ! {
	if roleids != ['*'] || roleids.len < 1 {
		return error('Invalid role ids')
	}
}

// ----------------- DTO 层 -----------------
pub struct RoleMenuListReq {
}

pub struct MenuMeta {
	affix                 bool   @[json: 'affix']              // Affix tab | 是否固定标签
	carry_param           bool   @[json: 'carryParam']         // The route carries parameters or not | 如果该路由会携带参数，且需要在tab页上面显示。则需要设置为true
	dynamic_level         u32    @[json: 'dynamicLevel']       // The maximum number of pages the router can open | 动态路由可打开Tab页数
	frame_src             string @[json: 'frameSrc']           // Iframe path | 内嵌iframe的地址
	hide_breadcrumb       bool   @[json: 'hideBreadcrumb']     // If hide the breadcrumb | 隐藏面包屑
	hide_children_in_menu bool   @[json: 'hideChildrenInMenu'] // Hide children menu or not | 隐藏所有子菜单
	hide_menu             bool   @[json: 'hideMenu']           // Hide menu | 隐藏菜单
	hide_tab              bool   @[json: 'hideTab']            // Hide the tab header | 当前路由不在标签页显示
	icon                  string @[json: 'icon']               // Menu Icon | 菜单图标 <= 50 字符
	ignore_keep_alive     bool   @[json: 'ignoreKeepAlive']    // Do not keep alive the tab | 不缓存Tab
	real_path             string @[json: 'realPath']           // The real path of the route without dynamic part | 动态路由的实际Path, 即去除路由的动态部分
	title                 string @[json: 'title']
}

pub struct MenuDataList {
	id           string   @[json: 'id']
	parent_id    string   @[json: 'parentId']
	menu_level   u64      @[json: 'level']
	menu_type    u64      @[json: 'menuType']
	meta         MenuMeta @[json: 'meta']
	path         string   @[json: 'path']
	name         string   @[json: 'name']
	trans        string   @[json: 'trans']
	redirect     string   @[json: 'redirect']
	component    string   @[json: 'component']
	disabled     bool     @[json: 'disabled']
	service_name string   @[json: 'serviceName']
	permission   string   @[json: 'permission']
	sort         u32      @[json: 'sort']
	created_at   int      @[json: 'createdAt']
	updated_at   int      @[json: 'updatedAt']
}

pub struct RoleMenuListResp {
	total int            @[json: 'total']
	data  []MenuDataList @[json: 'data']
}

// ----------------- Repository 层 -----------------
fn find_menuids_by_roleids(mut ctx Context, roleids []string) !RoleMenuListResp {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	mut result := []SysMenu{}
	if roleids == ['*'] {
		result = sql db {
			select from SysMenu
		} or { return error('Failed to query menu information: ${err}') }
	} else {
		// ------------------- 查询角色菜单关系 -------------------
		mut menu_id_arr := sql db {
			select from SysRoleMenu where role_id in roleids
		} or { return error('Failed to query role menu relationship: ${err}') }

		if menu_id_arr.len == 0 {
			return RoleMenuListResp{
				total: 0
				data:  []
			}
		}
		mut menu_ids := menu_id_arr.map(it.menu_id)

		// ------------------- 查询菜单信息 -------------------
		result = sql db {
			select from SysMenu where id in menu_ids
		} or { return error('Failed to query menu information: ${err}') }
	}

	mut datalist := []MenuDataList{}
	for row in result {
		datalist << MenuDataList{
			id:           row.id
			parent_id:    row.parent_id or { '' }
			menu_level:   row.menu_level
			menu_type:    row.menu_type
			meta:         MenuMeta{
				affix:                 (row.affix or { 1 }) == 1
				carry_param:           (row.carry_param or { 1 }) == 1
				dynamic_level:         row.dynamic_level or { 0 }
				frame_src:             row.frame_src or { '' }
				hide_breadcrumb:       (row.hide_breadcrumb or { 1 }) == 1
				hide_children_in_menu: (row.hide_children_in_menu or { 1 }) == 1
				hide_menu:             (row.hide_menu or { 1 }) == 1
				hide_tab:              (row.hide_tab or { 1 }) == 1
				icon:                  row.icon
				ignore_keep_alive:     true
				real_path:             row.real_path or { '' }
				title:                 ctx.i18n.t('${row.title}')
			}
			path:         row.path or { '' }
			name:         row.name.str()
			trans:        ctx.i18n.t('${row.title}')
			redirect:     row.redirect or { '' }
			component:    row.component or { '' }
			disabled:     (row.disabled or { 0 }) == 1
			service_name: row.service_name or { '' }
			permission:   row.permission or { '' }
			sort:         u32(row.sort)
			created_at:   row.created_at.format_ss().int()
			updated_at:   row.updated_at.format_ss().int()
		}
	}

	return RoleMenuListResp{
		total: result.len
		data:  datalist
	}
}
