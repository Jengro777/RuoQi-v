/*
获取角色菜单权限列表
*/
module role_permission

import veb
import log
import x.json2 as json
import structs.schema_sys { SysRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/role'; post]
pub fn (app &RolePermission) find_role_menu_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleMenuListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request: ${err.msg()}'))
	}

	result := find_role_menu_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Failed to get role menu list: ${err.msg()}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_role_menu_permission_usecase(mut ctx Context, req GetRoleMenuListReq) !GetRoleMenuListResp {
	// Domain 参数校验
	find_role_menu_permission_domain(req)!

	// Repository 查询数据
	return find_role_menu_permission(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn find_role_menu_permission_domain(req GetRoleMenuListReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleMenuListReq {
	role_id string @[json: 'id']
}

@[heap]
pub struct GetRoleMenuListResp {
	menu_ids []string @[json: 'menuIds']
	role_id  string   @[json: 'roleId']
}

// ----------------- Repository 层 -----------------
fn find_role_menu_permission(mut ctx Context, req GetRoleMenuListReq) !GetRoleMenuListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// --- 查询角色已有菜单 ID ---
	mut role_menus := sql db {
		select from SysRoleMenu where role_id == req.role_id
	} or { return error('Failed to query role menus: ${err}') }

	owned_menu_ids := role_menus.map(it.menu_id)

	return GetRoleMenuListResp{
		menu_ids: owned_menu_ids
		role_id:  req.role_id
	}
}
