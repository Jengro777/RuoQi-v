module position

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysPosition }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Position) position_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_position_usecase(mut ctx Context, req UpdatePositionReq) !UpdatePositionResp {
	// Domain 层校验
	update_position_domain(req)!

	// Repository 层执行更新
	return update_position(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_position_domain(req UpdatePositionReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdatePositionReq {
	id     string  @[json: 'id']
	status ?u8     @[json: 'status']
	name   ?string @[json: 'name']
	code   ?string @[json: 'code']
	remark ?string @[json: 'remark']
	sort   ?u64    @[json: 'sort']
}

pub struct UpdatePositionResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_position(mut ctx Context, req UpdatePositionReq) !UpdatePositionResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}
	time_now := time.now().format_ss()
	mut q := orm.new_query[SysPosition](db)

	if status := req.status {
		q.set('status = ?', status)!
	}
	if name := req.name {
		q.set('name = ?', name)!
	}
	if code := req.code {
		q.set('code = ?', code)!
	}
	if remark := req.remark {
		q.set('remark = ?', remark)!
	}
	if sort := req.sort {
		q.set('sort = ?', sort)!
	}

	q.set('updated_at = ?', time_now)!
		.where('id = ?', req.id)!
		.update()!

	return UpdatePositionResp{
		msg: 'Position updated successfully'
	}
}
