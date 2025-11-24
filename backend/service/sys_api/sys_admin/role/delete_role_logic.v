module role

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role/delete'; post]
pub fn(app &Role)role_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_role_usecase(mut ctx Context, req DeleteRoleReq) !DeleteRoleResp {
	// Domain 参数校验
	delete_role_domain(req)!

	// Repository 执行删除
	return delete_role(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_role_domain(req DeleteRoleReq) ! {
	if req.id == '' {
		return error('role id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteRoleReq {
	id string @[json: 'id']
}

pub struct DeleteRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_role(mut ctx Context, req DeleteRoleReq) !DeleteRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysRole](db)
	q.set('del_flag = ?', 1)!.where('id = ?', req.id)!.update()!

	return DeleteRoleResp{
		msg: 'Role deleted successfully'
	}
}
