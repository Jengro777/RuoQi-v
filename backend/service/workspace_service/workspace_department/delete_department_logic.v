module workspace_department

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_workspace { WsDepartment }
import common.api

// ═══ Handler ═══
@['/delete_department'; post]
pub fn (app &WorkspaceDepartment) delete_department_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_department_usecase(mut ctx Context, req DeleteDepartmentReq) !DeleteDepartmentResp {
	delete_department_domain(req)!
	return delete_department_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_department_domain(req DeleteDepartmentReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct DeleteDepartmentReq {
	id string @[json: 'id']
}

pub struct DeleteDepartmentResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_department_repo(mut ctx Context, req DeleteDepartmentReq) !DeleteDepartmentResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update WsDepartment set del_flag = -1, updated_at = time.now() where id == req.id
		&& del_flag == 0
	} or { return error('Failed to delete department: ${err}') }
	return DeleteDepartmentResp{
		msg: 'Department deleted'
	}
}
