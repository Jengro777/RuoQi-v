module workspace_department

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsDepartment }
import common.api

// ═══ Handler ═══
@['/create_department'; post]
pub fn (app &WorkspaceDepartment) create_department_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_department_usecase(mut ctx Context, req CreateDepartmentReq) !CreateDepartmentResp {
	create_department_domain(req)!
	return create_department_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_department_domain(req CreateDepartmentReq) ! {
	if req.name == '' {
		return error('name is required')
	}
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
}

// ═══ DTO ═══
pub struct CreateDepartmentReq {
	workspace_id string @[json: 'workspaceId']
	parent_id    string @[json: 'parentId']
	name         string @[json: 'name']
	code         string @[json: 'code']
	description  string @[json: 'description']
	sort         u32    @[json: 'sort']
}

pub struct CreateDepartmentResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_department_repo(mut ctx Context, req CreateDepartmentReq) !CreateDepartmentResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	d := WsDepartment{
		id:           rand.uuid_v7()
		workspace_id: req.workspace_id
		parent_id:    req.parent_id
		name:         req.name
		code:         req.code
		description:  req.description
		sort:         req.sort
		status:       0
		created_at:   time.now()
		updated_at:   time.now()
	}
	sql db {
		insert d into WsDepartment
	} or { return error('Failed: ${err}') }
	return CreateDepartmentResp{
		id:  d.id
		msg: 'Department created'
	}
}
