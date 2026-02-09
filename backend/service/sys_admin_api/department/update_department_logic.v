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
@['/update'; post]
pub fn (app &Department) update_department_handler(mut ctx Context) veb.Result {
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
	update_department_domain(req)!

	return update_department_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_department_domain(req UpdateDepartmentReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateDepartmentReq {
	id        string  @[json: 'id']
	name      ?string @[json: 'name']
	leader    ?string @[json: 'leader']
	phone     ?string @[json: 'phone']
	email     ?string @[json: 'email']
	remark    ?string @[json: 'remark']
	parent_id ?string @[json: 'parentId']
	status    ?u8     @[json: 'status']
	sort      ?u64    @[json: 'sort']
}

pub struct UpdateDepartmentResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_department_repo(mut ctx Context, req UpdateDepartmentReq) !UpdateDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now().format_ss()
	mut q := orm.new_query[SysDepartment](db)
	if parent_id := req.parent_id {
		q.set('parent_id = ?', parent_id)!
	}
	if name := req.name {
		q.set('name = ?', name)!
	}
	if leader := req.leader {
		q.set('leader = ?', leader)!
	}
	if phone := req.phone {
		q.set('phone = ?', phone)!
	}
	if email := req.email {
		q.set('email = ?', email)!
	}
	if remark := req.remark {
		q.set('remark = ?', remark)!
	}
	if status := req.status {
		q.set('status = ?', status)!
	}
	if sort := req.sort {
		q.set('sort = ?', sort)!
	}

	q.set('updated_at = ?', time_now)!
		.where('id = ?', req.id)!
		.update()!

	return UpdateDepartmentResp{
		msg: 'Department updated successfully'
	}
}
