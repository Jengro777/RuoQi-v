module project

import veb
import log
import x.json2 as json
import structs.schema_core { CoreProject }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/project/delete'; post]
pub fn (app &Project) project_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteProjectReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_project_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_project_usecase(mut ctx Context, req DeleteProjectReq) !DeleteProjectResp {
	// Domain 校验
	delete_project_domain(req)!

	// Repository 删除
	return delete_project_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_project_domain(req DeleteProjectReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteProjectReq {
	id string @[json: 'id'; required]
}

pub struct DeleteProjectResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_project_repo(mut ctx Context, req DeleteProjectReq) !DeleteProjectResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		delete from CoreProject where id == req.id
	} or { return error('Failed to delete project: ${err}') }

	return DeleteProjectResp{
		msg: 'Project deleted successfully'
	}
}
