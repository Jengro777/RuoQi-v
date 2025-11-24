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
@['/role/id'; post]
pub fn(app &Role)role_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RoleByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := role_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn role_by_id_usecase(mut ctx Context, req RoleByIdReq) !RoleByIdResp {
	// Domain 校验
	role_by_id_domain(req)!

	// Repository 获取数据
	return role_by_id(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn role_by_id_domain(req RoleByIdReq) ! {
	if req.id == '' {
		return error('role id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct RoleByIdReq {
	id string @[json: 'id']
}

pub struct RoleByIdResp {
	id              string @[json: 'id']
	status          int    @[json: 'status']
	name            string @[json: 'name']
	code            string @[json: 'code']
	default_router  string @[json: 'default_router']
	remark          string @[json: 'remark']
	sort            int    @[json: 'sort']
	data_scope      int    @[json: 'data_scope']
	custom_dept_ids string @[json: 'custom_dept_ids']
	created_at      string @[json: 'created_at']
	updated_at      string @[json: 'updated_at']
	deleted_at      string @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn role_by_id(mut ctx Context, req RoleByIdReq) !RoleByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysRole](db)
	mut query := q.select()!.where('id = ?', req.id)!
	result := query.query()!

	if result.len == 0 {
		return error('Role not found')
	}

	row := result[0]

	return RoleByIdResp{
		id:              row.id
		status:          int(row.status)
		name:            row.name
		code:            row.code
		default_router:  row.default_router
		remark:          row.remark or { '' }
		sort:            int(row.sort)
		data_scope:      int(row.data_scope)
		custom_dept_ids: row.custom_dept_ids or { '' }
		created_at:      row.created_at.format_ss()
		updated_at:      row.updated_at.format_ss()
		deleted_at:      (row.deleted_at or { time.Time{} }).format_ss()
	}
}
