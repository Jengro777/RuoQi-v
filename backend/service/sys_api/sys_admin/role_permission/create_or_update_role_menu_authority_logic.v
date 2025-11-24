module role_permission

import veb
import log
import x.json2 as json
import structs.schema_sys { SysRoleMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role_permission/update_menu'; post]
pub fn(app &RolePermission)update_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD} ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request body: ${err.msg()}'))
	}

	// Usecase 执行
	result := update_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_menu_usecase(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	// Domain 校验
	update_menu_domain(req)!

	// Repository 执行数据库操作
	return update_menu(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_menu_domain(req UpdateMenuReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
	if req.menu_ids.len == 0 {
		return error('menu_ids cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateMenuReq {
	tenant_id string   @[json: 'tenant_id']
	role_id   string   @[json: 'role_id']
	menu_ids  []string @[json: 'menu_ids']
}

pub struct UpdateMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_menu(mut ctx Context, req UpdateMenuReq) !UpdateMenuResp {
	mut db, conn := ctx.dbpool.acquire() or {
		return error('Failed to acquire DB connection: ${err}')
	}
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 开启事务
	db.begin() or { return error('Failed to begin transaction: ${err}') }

	// 删除旧权限
	sql db {
		delete from SysRoleMenu where role_id == req.role_id
	} or {
		db.rollback() or {}
		return error('Failed to delete old role-menu permissions: ${err}')
	}

	// 插入新权限
	for menu_id in req.menu_ids {
		new_perm := SysRoleMenu{
			role_id: req.role_id
			menu_id: menu_id
		}
		sql db {
			insert new_perm into SysRoleMenu
		} or {
			db.rollback() or {}
			return error('Failed to insert menu_id=${menu_id}: ${err}')
		}
	}

	// 提交事务
	db.commit() or {
		db.rollback() or {}
		return error('Failed to commit transaction: ${err}')
	}

	log.info('Updated ${req.menu_ids.len} menu permissions for role=${req.role_id}')
	return UpdateMenuResp{
		msg: 'Role menu permissions updated successfully'
	}
}
