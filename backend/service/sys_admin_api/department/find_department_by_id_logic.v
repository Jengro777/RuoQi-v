module department

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/'; post]
pub fn (app &Department) find_department_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FindDepartmentByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_department_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_department_by_id_usecase(mut ctx Context, req FindDepartmentByIdReq) !FindDepartmentByIdResp {
	find_department_by_id_domain(req)!

	return find_department_by_id(mut ctx, req.id)
}

// ----------------- Domain 层 -----------------
fn find_department_by_id_domain(req FindDepartmentByIdReq) ! {
	if req.id == '' {
		return error('department id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct FindDepartmentByIdReq {
	id string @[json: 'id']
}

pub struct FindDepartmentByIdResp {
	id         string @[json: 'id']
	parent_id  string @[json: 'parentId']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	leader     string @[json: 'leader']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	phone      string @[json: 'phone']
	email      string @[json: 'email']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn find_department_by_id(mut ctx Context, id string) !FindDepartmentByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	result := sql db {
		select from SysDepartment where id == id limit 1
	} or { return error('Failed to query department: ${err}') }

	if result.len == 0 {
		return error('department not found')
	}

	row := result[0]
	return FindDepartmentByIdResp{
		id:         row.id
		parent_id:  row.parent_id
		status:     int(row.status)
		name:       row.name
		leader:     row.leader or { '' }
		remark:     row.remark or { '' }
		sort:       int(row.sort)
		phone:      row.phone or { '' }
		email:      row.email or { '' }
		created_at: row.created_at.format_ss()
		updated_at: row.updated_at.format_ss()
		deleted_at: row.deleted_at or { time.Time{} }.format_ss()
	}
}
