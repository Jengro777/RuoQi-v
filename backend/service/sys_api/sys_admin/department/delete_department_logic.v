module department

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/department/delete'; post]
pub fn(app &Department)delete_department_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_department_usecase(mut ctx Context, req DeleteDepartmentReq) !DeleteDepartmentResp {
	// Domain 校验
	delete_department_domain(req)!

	// Repository 执行删除
	return delete_department_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_department_domain(req DeleteDepartmentReq) ! {
	if req.id == '' {
		return error('department id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteDepartmentReq {
	id string @[json: 'id']
}

pub struct DeleteDepartmentResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_department_repo(mut ctx Context, req DeleteDepartmentReq) !DeleteDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDepartment](db)
	// 逻辑删除
	q.delete()!.where('id = ?', req.id)!.update()!
	// 如果未来改为标记删除，可使用：
	// q.set('del_flag = ?', 1)!.where('id = ?', req.id)!.update()!

	return DeleteDepartmentResp{
		msg: 'Department deleted successfully'
	}
}
