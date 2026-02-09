module role

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_core { CoreRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role/list'; post]
pub fn tenant_role_list_handler(app &Role, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetTenantRoleListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_tenant_role_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_tenant_role_list_usecase(mut ctx Context, req GetTenantRoleListReq) !GetTenantRoleListResp {
	// Domain 参数校验
	validate_tenant_role_list_domain(req)!

	// Repository 查询
	return find_tenant_role_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn validate_tenant_role_list_domain(req GetTenantRoleListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetTenantRoleListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'page_size']
	name      string @[json: 'name']
	tenant_id string @[json: 'tenant_id']
}

pub struct GetTenantRoleListResp {
	total int
	data  []GetTenantRoleList
}

pub struct GetTenantRoleList {
	id             string    @[json: 'id']
	status         u8        @[default: 0; json: 'status']
	name           string    @[json: 'name']
	default_router string    @[json: 'default_router']
	remark         string    @[json: 'remark']
	sort           u64       @[json: 'sort']
	created_at     time.Time @[json: 'created_at']
	updated_at     time.Time @[json: 'updated_at']
	deleted_at     time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn find_tenant_role_list_repo(mut ctx Context, req GetTenantRoleListReq) !GetTenantRoleListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut core_role := orm.new_query[CoreRole](db)

	// 总数统计
	mut count := sql db {
		select count from CoreRole
	}!

	offset_num := (req.page - 1) * req.page_size

	mut query := core_role.select()!
	if req.tenant_id != '' {
		query = query.where('tenant_id = ?', req.tenant_id)!
	}
	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []GetTenantRoleList{}
	for row in result {
		datalist << GetTenantRoleList{
			id:             row.id
			status:         row.status
			name:           row.name
			default_router: row.default_router
			remark:         row.remark or { '' }
			sort:           row.sort
			created_at:     row.created_at
			updated_at:     row.updated_at
			deleted_at:     row.deleted_at or { time.Time{} }
		}
	}

	return GetTenantRoleListResp{
		total: count
		data:  datalist
	}
}
