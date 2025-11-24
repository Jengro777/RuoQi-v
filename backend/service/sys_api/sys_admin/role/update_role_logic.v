module role

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role/update'; post]
pub fn(app &Role)role_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_role_usecase(mut ctx Context, req UpdateRoleReq) !UpdateRoleResp {
	// 参数校验
	update_role_domain(req)!

	// 执行数据库更新
	return update_role(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_role_domain(req UpdateRoleReq) ! {
	if req.id == '' {
		return error('id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
	if req.code == '' {
		return error('code is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateRoleReq {
	id              string     @[json: 'id']
	status          u8         @[json: 'status']
	name            string     @[json: 'name']
	code            string     @[json: 'code']
	default_router  string     @[json: 'default_router']
	remark          string     @[json: 'remark']
	sort            u64        @[json: 'sort']
	data_scope      u8         @[json: 'data_scope']
	custom_dept_ids string     @[json: 'custom_dept_ids']
	updated_at      ?time.Time @[json: 'updated_at']
}

pub struct UpdateRoleResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_role(mut ctx Context, req UpdateRoleReq) !UpdateRoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysRole](db)

	q.set('status = ?', req.status)!
		.set('name = ?', req.name)!
		.set('code = ?', req.code)!
		.set('default_router = ?', req.default_router)!
		.set('remark = ?', req.remark)!
		.set('sort = ?', req.sort)!
		.set('data_scope = ?', req.data_scope)!
		.set('custom_dept_ids = ?', req.custom_dept_ids)!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateRoleResp{
		msg: 'Role updated successfully'
	}
}
