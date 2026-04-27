module token

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Token) update_token_handler(mut ctx Context) veb.Result {
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
	if req.token_id == '' {
		return error('token id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateTokenReq {
	user_id    ?string    @[json: 'uuid']
	token_id   string     @[json: 'id']
	status     ?u8        @[json: 'status']
	username   ?string    @[json: 'username']
	source     ?string    @[json: 'source']
	expired_at ?time.Time @[json: 'expiredAt']
	updated_at ?time.Time @[json: 'updatedAt']
}

pub struct UpdateTokenResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_token(mut ctx Context, req UpdateTokenReq) !UpdateTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if user_id := req.user_id { user_id == user_id },
		if status := req.status { status == status },
		if username := req.username { username == username },
		if source := req.source { source == source },
		if expired_at := req.expired_at { expired_at == expired_at },
		updated_at == time.now()
	}

	sql db {
		dynamic update SysToken set up_expr where id == req.token_id
	}!

	return UpdateTokenResp{
		msg: 'Token updated successfully'
	}
}
