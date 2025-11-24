module department

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/department/get_by_id'; post]
pub fn(app &Department)department_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetDepartmentByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_department_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_department_by_id_usecase(mut ctx Context, req GetDepartmentByIdReq) !GetDepartmentByIdResp {
	// Domain 校验
	get_department_by_id_domain(req)!

	// Repository 查询
	return get_department_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_department_by_id_domain(req GetDepartmentByIdReq) ! {
	if req.id == '' {
		return error('department id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetDepartmentByIdReq {
	id string @[json: 'id']
}

pub struct GetDepartmentByIdResp {
	id         string @[json: 'id']
	parent_id  string @[json: 'parent_id']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	leader     string @[json: 'leader']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	phone      string @[json: 'phone']
	email      string @[json: 'email']
	created_at string @[json: 'created_at']
	updated_at string @[json: 'updated_at']
	deleted_at string @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn get_department_by_id_repo(mut ctx Context, req GetDepartmentByIdReq) !GetDepartmentByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDepartment](db)
	mut query := q.select()!.where('id = ?', req.id)!
	result := query.query()!

	if result.len == 0 {
		return error('department not found')
	}

	row := result[0]
	return GetDepartmentByIdResp{
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
