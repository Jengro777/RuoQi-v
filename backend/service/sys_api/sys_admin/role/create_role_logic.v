module role

import veb
import log
import orm
import time
import x.json2 as json
import rand
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role/create'; post]
pub fn(app &Role)role_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_role_usecase(mut ctx Context, req CreateRoleReq) !CreateRoleResp {
	// Domain 参数校验
	create_role_domain(req)!

	// Repository 层写入数据库
	return create_role(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_role_domain(req CreateRoleReq) ! {
	if req.name == '' {
		return error('Role name is required')
	}
	if req.code == '' {
		return error('Role code is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateRoleReq {
	status          u8         @[json: 'status']
	name            string     @[json: 'name']
	code            string     @[json: 'code']
	default_router  string     @[json: 'default_router']
	remark          string     @[json: 'remark']
	sort            u32        @[json: 'sort']
	data_scope      u8         @[json: 'data_scope']
	custom_dept_ids string     @[json: 'custom_dept_ids']
	created_at      ?time.Time @[json: 'created_at']
	updated_at      ?time.Time @[json: 'updated_at']
}

pub struct CreateRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_role(mut ctx Context, req CreateRoleReq) !CreateRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysRole](db)

	role := SysRole{
		id:              rand.uuid_v7()
		status:          req.status
		name:            req.name
		code:            req.code
		default_router:  req.default_router
		remark:          req.remark
		sort:            req.sort
		data_scope:      req.data_scope
		custom_dept_ids: req.custom_dept_ids
		created_at:      req.created_at or { time.now() }
		updated_at:      req.updated_at or { time.now() }
	}

	q.insert(role)!

	return CreateRoleResp{
		msg: 'Role created successfully'
	}
}
