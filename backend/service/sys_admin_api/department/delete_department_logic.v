module department

import veb
import log
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &Department) delete_department_handler(mut ctx Context) veb.Result {
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
	delete_department_domain(req)!

	return delete_department_by_ids(mut ctx, req.ids)
}

// ----------------- Domain 层 -----------------
fn delete_department_domain(req DeleteDepartmentReq) ! {
	if req.ids == [] {
		return error('department ids is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteDepartmentReq {
	ids []string @[json: 'ids']
}

pub struct DeleteDepartmentResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_department_by_ids(mut ctx Context, ids []string) !DeleteDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from SysDepartment where id in ids
	} or { return error('Failed to delete department: ${err}') }

	return DeleteDepartmentResp{
		msg: 'Department deleted successfully'
	}
}
