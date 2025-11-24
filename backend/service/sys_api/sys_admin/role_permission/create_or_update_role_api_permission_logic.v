module role_permission

import veb
import log
import x.json2 as json
import structs.schema_sys { SysRoleApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role_permission/update_api'; post]
pub fn(app &RolePermission)update_api_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD} ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request body: ${err.msg()}'))
	}

	result := update_api_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_api_permission_usecase(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	// Domain 校验
	update_api_permission_domain(req)!

	// Repository 执行事务
	return update_api_permission(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_api_permission_domain(req UpdateApiReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
	if req.api_ids.len == 0 {
		return error('api_ids cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateApiReq {
	role_id string   @[json: 'role_id']
	api_ids []string @[json: 'api_ids']
}

pub struct UpdateApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_api_permission(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
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
		delete from SysRoleApi where role_id == req.role_id
	} or {
		db.rollback() or {}
		return error('Failed to delete old role-api permissions: ${err}')
	}

	// 插入新权限
	for api_id in req.api_ids {
		new_perm := SysRoleApi{
			role_id: req.role_id
			api_id:  api_id
		}
		sql db {
			insert new_perm into SysRoleApi
		} or {
			db.rollback() or {}
			return error('Failed to insert api_id=${api_id}: ${err}')
		}
	}

	// 提交事务
	db.commit() or {
		db.rollback() or {}
		return error('Failed to commit transaction: ${err}')
	}

	log.info('Updated ${req.api_ids.len} api permissions for role=${req.role_id}')
	return UpdateApiResp{
		msg: 'Role api permissions updated successfully'
	}
}
