module department

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/department/update'; post]
pub fn(app &Department)department_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_department_usecase(mut ctx Context, req UpdateDepartmentReq) !UpdateDepartmentResp {
	// Domain 校验
	update_department_domain(req)!

	// Repository 执行更新
	return update_department_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_department_domain(req UpdateDepartmentReq) ! {
	if req.id == '' {
		return error('id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateDepartmentReq {
	id         string     @[json: 'id']
	name       string     @[json: 'name']
	leader     string     @[json: 'leader']
	phone      string     @[json: 'phone']
	email      string     @[json: 'email']
	remark     string     @[json: 'remark']
	parent_id  string     @[json: 'parent_id']
	status     u8         @[json: 'status']
	sort       u64        @[json: 'sort']
	updated_at ?time.Time @[json: 'updated_at']
}

pub struct UpdateDepartmentResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_department_repo(mut ctx Context, req UpdateDepartmentReq) !UpdateDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDepartment](db)

	q.set('parent_id = ?', req.parent_id)!
		.set('name = ?', req.name)!
		.set('leader = ?', req.leader)!
		.set('phone = ?', req.phone)!
		.set('email = ?', req.email)!
		.set('remark = ?', req.remark)!
		.set('status = ?', req.status)!
		.set('sort = ?', req.sort)!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateDepartmentResp{
		msg: 'Department updated successfully'
	}
}
