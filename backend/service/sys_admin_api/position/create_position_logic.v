module position

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_sys { SysPosition }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Position) position_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_position_usecase(mut ctx Context, req CreatePositionReq) !CreatePositionResp {
	// Domain 参数校验
	create_position_domain(req)!

	// Repository 写入数据库
	return create_position(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_position_domain(req CreatePositionReq) ! {
	if req.name == '' {
		return error('Position name is required')
	}
	if req.code == '' {
		return error('Position code is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreatePositionReq {
	status u8     @[json: 'status']
	name   string @[json: 'name']
	code   string @[json: 'code']
	remark string @[json: 'remark']
	sort   u32    @[json: 'sort']
}

pub struct CreatePositionResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_position(mut ctx Context, req CreatePositionReq) !CreatePositionResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	time_now := time.now()
	position := SysPosition{
		id:         rand.uuid_v7()
		status:     req.status
		name:       req.name
		code:       req.code
		remark:     req.remark
		sort:       req.sort
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		insert position into SysPosition
	} or { return error('Failed to insert position: ${err}') }

	return CreatePositionResp{
		msg: 'Position created successfully'
	}
}
