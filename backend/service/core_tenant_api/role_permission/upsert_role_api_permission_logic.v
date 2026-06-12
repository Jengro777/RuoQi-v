// 根据租户ID和应用订阅ID,逐个设置租户角色的api权限
// step1 删除角色关联的租户的所有api权限
// step1 插入角色关联的租户的所有api权限
module role_permission

import orm
import veb
import log
import x.json2 as json
import structs.schema_core { CoreRoleApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role_permission/update_api'; post]
pub fn (app &RolePermission) upsert_role_api_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD} ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request body: ${err.msg()}'))
	}

	result := upsert_role_api_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn upsert_role_api_permission_usecase(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	// Domain 校验
	upsert_role_api_permission_domain(req)!

	// Repository 执行事务操作
	return upsert_role_api_permission_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn upsert_role_api_permission_domain(req UpdateApiReq) ! {
	if req.tenant_id == '' || req.role_id == '' || req.source_type == '' || req.source_id == '' {
		return error('Missing required fields: tenant_id / role_id / source_type / source_id')
	}
	if req.api_ids.len == 0 {
		return error('api_ids cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateApiReq {
	tenant_id   string   @[json: 'tenant_id']
	role_id     string   @[json: 'role_id']
	api_ids     []string @[json: 'api_ids']
	source_type string   @[json: 'source_type']
	source_id   string   @[json: 'source_id']
}

pub struct UpdateApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn upsert_role_api_permission_repo(mut ctx Context, req UpdateApiReq) !UpdateApiResp {
	mut db, conn := ctx.dbpool.acquire() or {
		return error('Failed to acquire DB connection: ${err}')
	}
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 开启事务
	mut scoped := orm.new_db(db, orm.DataScope{})
	scoped.orm_begin() or { return error('Failed to begin transaction: ${err}') }

	// Step 1: 删除旧权限
	sql scoped {
		delete from CoreRoleApi where role_id == req.role_id && source_type == req.source_type
		&& source_id == req.source_id
	} or {
		scoped.orm_rollback() or {}
		return error('Failed to delete old role-api permissions: ${err}')
	}

	// Step 2: 插入新权限
	for api_id in req.api_ids {
		new_perm := CoreRoleApi{
			role_id:     req.role_id
			api_id:      api_id
			source_type: req.source_type
			source_id:   req.source_id
		}
		sql scoped {
			insert new_perm into CoreRoleApi
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
	return UpdateApiResp{
		msg: 'Role api permissions updated successfully'
	}
}
