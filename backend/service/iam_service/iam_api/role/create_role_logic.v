module role

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamRole }
import common.api

// ═══ Handler ═══
@['/create_role'; post]
pub fn (app &Role) create_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_role_usecase(mut ctx Context, req CreateRoleReq) !RoleResp {
	create_role_domain(req)!
	create_role_repo(mut ctx, req)!
	return RoleResp{
		msg: 'Role created'
	}
}

// ═══ Domain ═══
fn create_role_domain(req CreateRoleReq) ! {
	if req.name == '' {
		return error('role name is required')
	}
	if req.code == '' {
		return error('role code is required')
	}
}

// ═══ DTO ═══
pub struct CreateRoleReq {
	name   string @[json: 'name']
	code   string @[json: 'code']
	remark string @[json: 'remark']
	sort   u32    @[json: 'sort']
	status u8     @[json: 'status']
}

pub struct RoleResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_role_repo(mut ctx Context, req CreateRoleReq) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	r := IamRole{
		id:         rand.uuid_v7()
		name:       req.name
		code:       req.code
		remark:     req.remark
		sort:       req.sort
		status:     req.status
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert r into IamRole
	}!
}
