module token

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/token/update'; post]
pub fn(app &Token)token_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_token_usecase(mut ctx Context, req UpdateTokenReq) !UpdateTokenResp {
	// Domain 校验
	update_token_domain(req)!

	// Repository 更新
	return update_token(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_token_domain(req UpdateTokenReq) ! {
	if req.id == '' {
		return error('token id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateTokenReq {
	id         string     @[json: 'id']
	status     u8         @[json: 'status']
	username   string     @[json: 'username']
	source     string     @[json: 'source']
	expired_at ?time.Time @[json: 'expired_at']
	updated_at ?time.Time @[json: 'updated_at']
}

pub struct UpdateTokenResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_token(mut ctx Context, req UpdateTokenReq) !UpdateTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysToken](db)

	q.set('status = ?', req.status)!
		.set('username = ?', req.username)!
		.set('source = ?', req.source)!
		.set('expired_at = ?', req.expired_at or { time.now() })!
		.set('updated_at = ?', req.updated_at or { time.now() })!
		.where('id = ?', req.id)!
		.update()!

	return UpdateTokenResp{
		msg: 'Token updated successfully'
	}
}
