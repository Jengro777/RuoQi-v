module role

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role/id'; post]
pub fn role_by_id_handler(app &Role, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetTenantRoleByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_tenant_role_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_tenant_role_by_id_usecase(mut ctx Context, req GetTenantRoleByIdReq) ![]GetCoreApiByListResp {
	// Domain 校验
	get_tenant_role_domain(req)!

	// Repository 获取数据
	return get_tenant_role_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_tenant_role_domain(req GetTenantRoleByIdReq) ! {
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetTenantRoleByIdReq {
	role_id   string @[json: 'role_id']
	tenant_id string @[json: 'tenant_id']
}

pub struct GetCoreApiByListResp {
	id             string    @[json: 'id']
	status         u8        @[default: 0; json: 'status']
	name           string    @[json: 'name']
	code           string    @[json: 'code']
	default_router string    @[json: 'default_router']
	remark         string    @[json: 'remark']
	sort           u64       @[json: 'sort']
	data_scope     u8        @[json: 'data_scope']
	created_at     time.Time @[json: 'created_at']
	updated_at     time.Time @[json: 'updated_at']
	deleted_at     time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn get_tenant_role_repo(mut ctx Context, req GetTenantRoleByIdReq) ![]GetCoreApiByListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	mut q_role := orm.new_query[SysRole](db)
	mut query := q_role.select()!
	if req.role_id != '' {
		query = query.where('id = ?', req.role_id)!
	}
	result := query.query()!

	mut datalist := []GetCoreApiByListResp{}
	for row in result {
		datalist << GetCoreApiByListResp{
			id:             row.id
			status:         row.status
			name:           row.name
			code:           row.code
			default_router: row.default_router
			remark:         row.remark or { '' }
			sort:           row.sort
			data_scope:     row.data_scope
			created_at:     row.created_at
			updated_at:     row.updated_at
			deleted_at:     row.deleted_at or { time.Time{} }
		}
	}

	return datalist
}
