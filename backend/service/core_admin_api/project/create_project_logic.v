module project

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_core { CoreProject }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/project/create'; post]
pub fn project_create_handler(app &Project, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateCoreProjectReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_project_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_project_usecase(mut ctx Context, req CreateCoreProjectReq) !CreateCoreProjectResp {
	// Domain 参数校验
	create_project_domain(req)!

	// Repository 写入数据库
	return create_project_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_project_domain(req CreateCoreProjectReq) ! {
	if req.name == '' {
		return error('name is required')
	}
	if req.logo == '' {
		return error('logo is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateCoreProjectReq {
	name         string  @[json: 'name'; required]
	display_name ?string @[json: 'display_name']
	logo         string  @[json: 'logo']
	description  ?string @[json: 'description']
}

pub struct CreateCoreProjectResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_project_repo(mut ctx Context, req CreateCoreProjectReq) !CreateCoreProjectResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now()
	project := CoreProject{
		id:           rand.uuid_v7()
		name:         req.name
		display_name: req.display_name or { '' }
		logo:         req.logo
		description:  req.description or { '' }
		created_at:   time_now
		updated_at:   time_now
	}

	sql db {
		insert project into CoreProject
	} or { return error('Failed to insert project: ${err}') }

	return CreateCoreProjectResp{
		msg: 'Project created successfully'
	}
}
