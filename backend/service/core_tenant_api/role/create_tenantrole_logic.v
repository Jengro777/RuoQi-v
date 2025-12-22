module role

import veb
import log
import orm
import time
import x.json2 as json
import rand
import structs.schema_core { CoreRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role/create'; post]
pub fn tenant_role_create_handler(app &Role, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateTenantRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_tenant_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_tenant_role_usecase(mut ctx Context, req CreateTenantRoleReq) !CreateTenantRoleResp {
	// Domain 校验
	create_tenant_role_domain(req)!

	// Repository 插入数据库
	return create_tenant_role_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_tenant_role_domain(req CreateTenantRoleReq) ! {
	if req.tenant_id == '' {
		return error('tenant_id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
	if req.default_router == '' {
		return error('default_router is required')
	}
	if req.type == '' {
		return error('type is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateTenantRoleReq {
	id             string  @[json: 'id']
	tenant_id      string  @[json: 'tenant_id']
	name           string  @[json: 'name']
	default_router string  @[json: 'default_router']
	remark         ?string @[json: 'remark']
	sort           u32     @[json: 'sort']
	status         u8      @[json: 'status']
	type           string  @[json: 'type']
	updater_id     ?string @[json: 'updater_id']
	creator_id     ?string @[json: 'creator_id']
}

pub struct CreateTenantRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_tenant_role_repo(mut ctx Context, req CreateTenantRoleReq) !CreateTenantRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now()

	mut q_role := orm.new_query[CoreRole](db)

	role := CoreRole{
		id:             rand.uuid_v7()
		tenant_id:      req.tenant_id
		name:           req.name
		default_router: req.default_router
		remark:         req.remark
		sort:           req.sort
		status:         req.status
		type:           req.type
		updater_id:     req.updater_id
		updated_at:     time_now
		creator_id:     req.creator_id
		created_at:     time_now
	}

	q_role.insert(role)!

	return CreateTenantRoleResp{
		msg: 'Tenant role created successfully'
	}
}
