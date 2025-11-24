module role_permission

import veb
import log
import x.json2 as json
import structs.schema_sys { SysMenu, SysRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu_list'; post]
pub fn(app &RolePermission)role_menu_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleMenuListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request: ${err.msg()}'))
	}

	result := get_role_menu_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Failed to get role menu list: ${err.msg()}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_role_menu_list_usecase(mut ctx Context, req GetRoleMenuListReq) ![]&GetRoleMenuListResp {
	// Domain 参数校验
	get_role_menu_list_domain(req)!

	// Repository 查询数据
	return get_role_menu_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_role_menu_list_domain(req GetRoleMenuListReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleMenuListReq {
	role_id string @[json: 'role_id']
}

@[heap]
pub struct GetRoleMenuListResp {
	id             string @[json: 'id']
	parent_id      string @[json: 'parent_id']
	menu_level     u64    @[json: 'menu_level']
	menu_type      u64    @[json: 'menu_type']
	name           string @[json: 'name']
	has_permission bool   @[json: 'has_permission']
mut:
	children []&GetRoleMenuListResp
}

// ----------------- Repository 层 -----------------
fn get_role_menu_list(mut ctx Context, req GetRoleMenuListReq) ![]&GetRoleMenuListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// --- 查询角色已有菜单 ID ---
	mut role_menus := sql db {
		select from SysRoleMenu where role_id == req.role_id
	} or { return error('Failed to query role menus: ${err}') }

	owned_menu_ids := role_menus.map(it.menu_id)

	// --- 查询所有菜单 ---
	mut all_menus := sql db {
		select from SysMenu
	} or { return error('Failed to query all menus: ${err}') }

	// --- 构造列表 + 标记权限 ---
	mut datalist := []&GetRoleMenuListResp{}
	for row in all_menus {
		datalist << &GetRoleMenuListResp{
			id:             row.id
			parent_id:      row.parent_id or { '0' }
			menu_level:     row.menu_level
			menu_type:      row.menu_type
			name:           row.name
			has_permission: row.id in owned_menu_ids
			children:       []&GetRoleMenuListResp{}
		}
	}

	// --- 构造树形结构 ---
	return build_menu_tree(mut datalist)
}

// ----------------- 构造树形结构函数 -----------------
fn build_menu_tree(mut flat_list []&GetRoleMenuListResp) []&GetRoleMenuListResp {
	mut tree := []&GetRoleMenuListResp{}
	mut lookup := map[string]&GetRoleMenuListResp{}

	// 构建 id -> 节点映射
	for item in flat_list {
		lookup[item.id] = item
	}

	// 构造树
	for item in flat_list {
		if item.parent_id == '0' || item.parent_id == '' {
			tree << item
		} else if mut parent := lookup[item.parent_id] {
			parent.children << item
		}
	}

	return tree
}
