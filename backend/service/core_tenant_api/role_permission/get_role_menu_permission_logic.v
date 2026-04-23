// 根据租户ID和应用订阅ID,获取租户角色的菜单权限列表,菜单权限包括有权限无权限
module role_permission

import veb
import log
import x.json2 as json
import structs.schema_core { CoreMenu, CoreRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role_permission/menu_list'; post]
pub fn (app &RolePermission) role_menu_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleMenuListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request: ${err.msg()}'))
	}

	result := role_menu_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Failed to get role menu list: ${err.msg()}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn role_menu_permission_usecase(mut ctx Context, req GetRoleMenuListReq) ![]&GetRoleMenuListResp {
	role_menu_permission_domain(req)!
	return role_menu_permission_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn role_menu_permission_domain(req GetRoleMenuListReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
	if req.source_id == '' {
		return error('source_id is required')
	}
	if req.source_type == '' {
		return error('source_type is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleMenuListReq {
	source_type string @[json: 'source_type']
	source_id   string @[json: 'source_id']
	tenant_id   string @[json: 'tenant_id']
	role_id     string @[json: 'role_id']
}

@[heap]
pub struct GetRoleMenuListResp {
	id             string @[json: 'id']
	parent_id      string @[json: 'parent_id']
	menu_level     u64    @[json: 'menu_level']
	menu_type      u64    @[json: 'menu_type']
	name           string @[json: 'name']
	source_type    string @[json: 'source_type']
	source_id      string @[json: 'source_id']
	has_permission bool   @[json: 'has_permission']
mut:
	children []&GetRoleMenuListResp
}

// ----------------- Repository 层 -----------------
fn role_menu_permission_repo(mut ctx Context, req GetRoleMenuListReq) ![]&GetRoleMenuListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// --- 1. 查询角色已有菜单 ---
	mut role_menus := sql db {
		select from CoreRoleMenu where role_id == req.role_id && source_type == req.source_type
		&& source_id == req.source_id
	} or { return error('Failed to query role menus: ${err}') }

	owned_menu_ids := role_menus.map(it.menu_id)

	// --- 2. 查询所有菜单 ---
	mut all_menus := sql db {
		select from CoreMenu where source_type == req.source_type && source_id == req.source_id
	} or { return error('Failed to query all menus: ${err}') }

	// --- 3. 构造列表 + 权限标记 ---
	mut datalist := []&GetRoleMenuListResp{}
	for row in all_menus {
		datalist << &GetRoleMenuListResp{
			id:             row.id
			parent_id:      row.parent_id or { '0' }
			menu_level:     row.menu_level
			menu_type:      row.menu_type
			name:           row.name
			source_type:    row.source_type
			source_id:      row.source_id
			has_permission: row.id in owned_menu_ids
			children:       []&GetRoleMenuListResp{}
		}
	}

	// --- 4. 构造树形 ---
	return build_menu_tree(mut datalist)
}

// ----------------- 构造树形函数 -----------------
fn build_menu_tree(mut flat_list []&GetRoleMenuListResp) []&GetRoleMenuListResp {
	mut tree := []&GetRoleMenuListResp{}
	mut lookup := map[string]&GetRoleMenuListResp{}

	for item in flat_list {
		lookup[item.id] = item
	}

	for item in flat_list {
		if item.parent_id == '0' || item.parent_id == '' {
			tree << item
		} else if mut parent := lookup[item.parent_id] {
			parent.children << item
		}
	}

	return tree
}
