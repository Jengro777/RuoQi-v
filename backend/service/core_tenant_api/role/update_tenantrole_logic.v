module role

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_core { CoreRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role/update'; post]
pub fn tenant_role_update_handler(app &Role, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateTenantRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_tenant_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_tenant_role_usecase(mut ctx Context, req UpdateTenantRoleReq) !UpdateTenantRoleResp {
	// Domain 校验层
	update_tenant_role_domain(req)!

	// Repository 写入数据库
	return update_tenant_role_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_tenant_role_domain(req UpdateTenantRoleReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
	if req.code == '' {
		return error('code is required')
	}
	// 其他字段根据需要可以加校验
}

// ----------------- DTO 层 -----------------
pub struct UpdateTenantRoleReq {
	role_id        string    @[json: 'role_id']
	tenant_id      string    @[json: 'tenant_id']
	status         u8        @[default: 0; json: 'status']
	name           string    @[json: 'name']
	code           string    @[json: 'code']
	default_router string    @[json: 'default_router']
	remark         string    @[json: 'remark']
	sort           u64       @[json: 'sort']
	data_scope     u8        @[json: 'data_scope']
	updated_at     time.Time @[json: 'updated_at']
}

pub struct UpdateTenantRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_tenant_role_repo(mut ctx Context, req UpdateTenantRoleReq) !UpdateTenantRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[CoreRole](db)

	q.set('status = ?', req.status)!
		.set('name = ?', req.name)!
		.set('code = ?', req.code)!
		.set('default_router = ?', req.default_router)!
		.set('remark = ?', req.remark)!
		.set('sort = ?', req.sort)!
		.set('data_scope = ?', req.data_scope)!
		.set('updated_at = ?', req.updated_at)!
		.where('id = ?', req.role_id)!
		.update()!

	return UpdateTenantRoleResp{
		msg: 'Update Tenant Role successfully'
	}
}
