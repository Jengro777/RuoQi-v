// 根据租户ID和应用订阅ID,逐个设置租户角色的菜单权限
// step1 删除角色关联的租户的所有菜单权限
// step2 插入角色关联的租户的所有菜单权限

module role_permission

import orm
import veb
import log
import x.json2 as json
import structs.schema_core { CoreRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role_permission/update_menu'; post]
pub fn (app &RolePermission) upsert_role_menu_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD} ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request body: ${err.msg()}'))
	}

	// Usecase 执行
	result := upsert_role_menu_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn upsert_role_menu_permission_usecase(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	// Domain 校验
	upsert_role_menu_permission_domain(req)!

	// Repository 写入数据库
	return upsert_role_menu_permission_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn upsert_role_menu_permission_domain(req UpdateMenuReq) ! {
	if req.role_id == '' || req.tenant_id == '' || req.source_type == '' || req.source_id == '' {
		return error('Missing required fields: tenant_id / role_id / source_type / source_id')
	}
	if req.menu_ids.len == 0 {
		return error('menu_ids cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateMenuReq {
	tenant_id   string   @[json: 'tenant_id']
	role_id     string   @[json: 'role_id']
	menu_ids    []string @[json: 'menu_ids']
	source_type string   @[json: 'source_type']
	source_id   string   @[json: 'source_id']
}

pub struct UpdateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn upsert_role_menu_permission_repo(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	mut db, conn := ctx.dbpool.acquire() or {
		return error('Failed to acquire DB connection: ${err}')
	}
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 开启事务
	mut scoped := orm.new_db(db, orm.DataScope{})
	scoped.orm_begin() or { return error('Failed to begin transaction: ${err}') }

	// Step 1: 删除旧菜单权限
	sql scoped {
		delete from CoreRoleMenu where role_id == req.role_id && source_type == req.source_type
		&& source_id == req.source_id
	} or {
		scoped.orm_rollback() or {}
		return error('Failed to delete old role-menu permissions: ${err}')
	}

	// Step 2: 插入新菜单权限
	for menu_id in req.menu_ids {
		new_perm := CoreRoleMenu{
			role_id:     req.role_id
			menu_id:     menu_id
			source_type: req.source_type
			source_id:   req.source_id
		}
		sql scoped {
			insert new_perm into CoreRoleMenu
		} or {
			scoped.orm_rollback() or {}
			return error('Failed to insert menu_id=${menu_id}: ${err}')
		}
	}

	// 提交事务
	scoped.orm_commit() or {
		scoped.orm_rollback() or {}
		return error('Failed to commit transaction: ${err}')
	}

	log.info('Updated ${req.menu_ids.len} menu permissions for role=${req.role_id}')
	return UpdateMenuResp{
		msg: 'Role menu permissions updated successfully'
	}
}
