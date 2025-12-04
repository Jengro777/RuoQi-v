module role

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/'; post]
pub fn (app &Role) find_role_by_id_handler(mut ctx Context) veb.Result {
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
	return find_role_by_id(mut ctx, req.id)
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
	default_router  string @[json: 'defaultRouter']
	remark          string @[json: 'remark']
	sort            int    @[json: 'sort']
	data_scope      int    @[json: 'dataScope']
	custom_dept_ids string @[json: 'customDeptIds']
	created_at      string @[json: 'createdAt']
	updated_at      string @[json: 'updatedAt']
	deleted_at      string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn find_role_by_id(mut ctx Context, id string) !RoleByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	result := sql db {
		select from SysRole where id == id
	} or { return error('Failed to query role by id: ${err}') }

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
