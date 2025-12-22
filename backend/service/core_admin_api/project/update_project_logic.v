module project

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_core { CoreProject }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/project/update'; post]
pub fn project_update_handler(app &Project, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateCoreProjectReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_project_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_project_usecase(mut ctx Context, req UpdateCoreProjectReq) !UpdateCoreProjectResp {
	// Domain 层参数校验
	update_project_domain(req)!

	// Repository 层执行更新
	return update_project_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_project_domain(req UpdateCoreProjectReq) ! {
	if req.id == '' {
		return error('id is required')
	}
	if req.name == '' {
		return error('name is required')
	}
	if req.logo == '' {
		return error('logo is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateCoreProjectReq {
	id           string  @[json: 'id'; required]
	name         string  @[json: 'name']
	display_name ?string @[json: 'display_name']
	logo         string  @[json: 'logo']
	description  ?string @[json: 'description']
}

pub struct UpdateCoreProjectResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_project_repo(mut ctx Context, req UpdateCoreProjectReq) !UpdateCoreProjectResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[CoreProject](db)

	q.set('name = ?', req.name)!
		.set('description = ?', req.description or { '' })!
		.set('display_name = ?', req.display_name or { '' })!
		.set('logo = ?', req.logo)!
		.set('updated_at = ?', time.now())!
		.where('id = ?', req.id)!
		.update()!

	return UpdateCoreProjectResp{
		msg: 'Project updated successfully'
	}
}
