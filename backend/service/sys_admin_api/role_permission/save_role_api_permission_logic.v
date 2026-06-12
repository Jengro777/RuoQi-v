/*
创建或更新API权限
*/
module role_permission

import orm
import veb
import log
import x.json2 as json
import structs.schema_sys { SysRoleApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/create_or_update'; post]
pub fn (app &RolePermission) save_role_api_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD} ${@MOD}.${@FILE_LINE}')

	req := json.decode[SaveApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request body: ${err.msg()}'))
	}

	result := save_role_api_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn save_role_api_permission_usecase(mut ctx Context, req SaveApiReq) !SaveApiResp {
	// Domain 校验
	save_role_api_permission_domain(req)!

	// Repository 执行事务
	return save_role_api_permission(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn save_role_api_permission_domain(req SaveApiReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
	if req.api_ids.len == 0 {
		return error('api_ids cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct SaveApiReq {
	role_id string   @[json: 'roleId']
	api_ids []string @[json: 'apiIds']
}

pub struct SaveApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn save_role_api_permission(mut ctx Context, req SaveApiReq) !SaveApiResp {
	mut db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// 开启事务
	mut scoped := orm.new_db(db, orm.DataScope{})
	scoped.orm_begin() or { return error('Failed to begin transaction: ${err}') }

	// 删除旧权限
	sql scoped {
		delete from SysRoleApi where role_id == req.role_id
	} or {
		scoped.orm_rollback() or {}
		return error('Failed to delete old role-api permissions: ${err}')
	}

	// 插入新权限
	for api_id in req.api_ids {
		new_perm := SysRoleApi{
			role_id: req.role_id
			api_id:  api_id
		}
		sql scoped {
			insert new_perm into SysRoleApi
		} or {
			scoped.orm_rollback() or {}
			return error('Failed to insert api_id=${api_id}: ${err}')
		}
	}

	// 提交事务
	scoped.orm_commit() or {
		scoped.orm_rollback() or {}
		return error('Failed to commit transaction: ${err}')
	}

	log.info('Updated ${req.api_ids.len} api permissions for role=${req.role_id}')
	return SaveApiResp{
		msg: 'Role api permissions updated successfully'
	}
}
