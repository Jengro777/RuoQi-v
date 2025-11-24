module position

import veb
import log
import orm
import time
import x.json2 as json
import rand
import structs.schema_sys { SysPosition }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/position/create'; post]
pub fn(app &Position)position_create_handler(mut ctx Context) veb.Result {
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
	status     u8         @[json: 'status']
	name       string     @[json: 'name']
	code       string     @[json: 'code']
	remark     string     @[json: 'remark']
	sort       u32        @[json: 'sort']
	created_at ?time.Time @[json: 'created_at']
	updated_at ?time.Time @[json: 'updated_at']
}

pub struct CreatePositionResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_position(mut ctx Context, req CreatePositionReq) !CreatePositionResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysPosition](db)

	position := SysPosition{
		id:         rand.uuid_v7()
		status:     req.status
		name:       req.name
		code:       req.code
		remark:     req.remark
		sort:       req.sort
		created_at: req.created_at or { time.now() }
		updated_at: req.updated_at or { time.now() }
	}

	q.insert(position)!

	return CreatePositionResp{
		msg: 'Position created successfully'
	}
}
