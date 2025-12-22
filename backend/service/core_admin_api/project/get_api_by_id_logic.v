module project

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_core { CoreProject }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/project/id'; post]
pub fn project_by_id_handler(app &Project, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetCoreProjectByIDReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := project_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn project_by_id_usecase(mut ctx Context, req GetCoreProjectByIDReq) ![]GetCoreProjectByIDResp {
	// Domain 校验
	project_by_id_domain(req)!

	// Repository 查询
	return project_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn project_by_id_domain(req GetCoreProjectByIDReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetCoreProjectByIDReq {
	id string @[json: 'id'; required]
}

pub struct GetCoreProjectByIDResp {
	id           string     @[json: 'id']
	name         string     @[json: 'name'; required]
	display_name ?string    @[json: 'display_name']
	logo         string     @[json: 'logo']
	description  ?string    @[json: 'description']
	created_at   ?time.Time @[json: 'created_at']
	updated_at   ?time.Time @[json: 'updated_at']
	deleted_at   ?time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn project_by_id_repo(mut ctx Context, req GetCoreProjectByIDReq) ![]GetCoreProjectByIDResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[CoreProject](db)
	mut query := q.select()!
	query = query.where('id = ?', req.id)!.limit(1)!

	result := query.query()!
	if result.len == 0 {
		return error('Project not found')
	}

	mut datalist := []GetCoreProjectByIDResp{}
	for row in result {
		datalist << GetCoreProjectByIDResp{
			id:           row.id
			name:         row.name
			display_name: row.display_name
			logo:         row.logo
			description:  row.description
			created_at:   row.created_at
			updated_at:   row.updated_at
			deleted_at:   row.deleted_at
		}
	}

	return datalist
}
