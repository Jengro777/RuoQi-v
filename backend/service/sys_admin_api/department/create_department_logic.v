module department

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Department) create_department_handler(mut ctx Context) veb.Result {
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
	if req.parent_id == '' {
		return error('Parent ID is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateDepartmentReq {
	parent_id string  @[json: 'parentId']
	status    u8      @[json: 'status']
	name      string  @[json: 'name']
	leader    ?string @[json: 'leader']
	sort      ?u32    @[json: 'sort']
	email     ?string @[json: 'email']
	phone     ?string @[json: 'phone']
	remark    ?string @[json: 'remark']
}

pub struct CreateDepartmentResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_department_repo(mut ctx Context, req CreateDepartmentReq) !CreateDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	time_now := time.now()
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
		sort:       req.sort or { 0 }
		email:      req.email
		phone:      req.phone
		remark:     req.remark
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		insert department into SysDepartment
	} or { return error('Failed to create department: ${err}') }

	return CreateDepartmentResp{
		msg: 'Department created successfully'
	}
}
