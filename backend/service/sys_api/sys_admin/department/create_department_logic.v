module department

import veb
import log
import orm
import time
import rand
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/department/create'; post]
pub fn(app &Department)department_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn create_department_usecase(mut ctx Context, req CreateDepartmentReq) !CreateDepartmentResp {
	create_department_domain(req)!
	return create_department_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_department_domain(req CreateDepartmentReq) ! {
	if req.name == '' {
		return error('Department name is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateDepartmentReq {
	parent_id  string     @[json: 'parent_id']
	status     u8         @[json: 'status']
	name       string     @[json: 'name']
	leader     string     @[json: 'leader']
	sort       u32        @[json: 'sort']
	phone      string     @[json: 'phone']
	remark     string     @[json: 'remark']
	created_at ?time.Time @[json: 'created_at']
	updated_at ?time.Time @[json: 'updated_at']
}

pub struct CreateDepartmentResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_department_repo(mut ctx Context, req CreateDepartmentReq) !CreateDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDepartment](db)

	department := SysDepartment{
		id:         rand.uuid_v7()
		parent_id:  if req.parent_id == '' {
			'00000000-0000-0000-0000-000000000000'
		} else {
			req.parent_id
		}
		status:     req.status
		name:       req.name
		leader:     req.leader
		sort:       req.sort
		phone:      req.phone
		remark:     req.remark
		created_at: req.created_at or { time.now() }
		updated_at: req.updated_at or { time.now() }
	}

	q.insert(department)!

	return CreateDepartmentResp{
		msg: 'Department created successfully'
	}
}
