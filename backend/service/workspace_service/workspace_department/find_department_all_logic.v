module workspace_department

import veb
import log
import json2 as json
import model { Context }
import model.schema_workspace { WsDepartment }
import common.api

// ═══ Handler ═══
@['/find_department_all'; post]
pub fn (app &WorkspaceDepartment) find_department_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindDepartmentAllReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := find_department_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_department_all_usecase(mut ctx Context, req FindDepartmentAllReq) ![]WsDepartment {
	return find_department_all_repo(mut ctx, req)
}

// ═══ DTO ═══
pub struct FindDepartmentAllReq {
	workspace_id string @[json: 'workspaceId']
}

// ═══ Repository ═══
fn find_department_all_repo(mut ctx Context, req FindDepartmentAllReq) ![]WsDepartment {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	return sql db {
		select from WsDepartment where workspace_id == req.workspace_id && del_flag == 0 order by sort
	} or { return error('Failed: ${err}') }
}
