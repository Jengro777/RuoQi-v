module position

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysPosition }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/'; post]
pub fn (app &Position) find_position_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetPositionByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_position_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn find_position_by_id_usecase(mut ctx Context, req GetPositionByIdReq) !GetPositionByIdResp {
	// Domain 层参数校验
	find_position_by_id_domain(req)!

	// Repository 层查询
	return find_position_by_id(mut ctx, req.id)
}

// ----------------- Domain 层 -----------------
fn find_position_by_id_domain(req GetPositionByIdReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetPositionByIdReq {
	id string @[json: 'id']
}

pub struct GetPositionByIdResp {
	id         string @[json: 'id']
	status     u8     @[json: 'status']
	name       string @[json: 'name']
	code       string @[json: 'code']
	remark     string @[json: 'remark']
	sort       u32    @[json: 'sort']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn find_position_by_id(mut ctx Context, id string) !GetPositionByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	mut result := sql db {
		select from SysPosition where id == id
	}!

	if result.len == 0 {
		return error('Position not found')
	}

	row := result[0]

	return GetPositionByIdResp{
		id:         row.id
		status:     row.status
		name:       row.name
		code:       row.code
		remark:     row.remark or { '' }
		sort:       row.sort
		created_at: row.created_at.format_ss()
		updated_at: row.updated_at.format_ss()
		deleted_at: row.deleted_at or { time.Time{} }.format_ss()
	}
}
