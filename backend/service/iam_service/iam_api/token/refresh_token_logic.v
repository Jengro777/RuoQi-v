module token

import veb
import log
import time
import json2 as json
import structs { Context }
import structs.schema_iam { IamToken }
import common.api

@['/refresh_token'; post]
pub fn (app &Token) refresh_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[RefreshTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := refresh_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

fn refresh_token_usecase(mut ctx Context, req RefreshTokenReq) !RefreshTokenResp {
	login_ip := ctx.req.header.get_custom('X-Forwarded-For') or { '' }
	device_id := ctx.req.header.get_custom('X-Device-ID') or { '' }
	token_jwt :=
		generate_iam_token(mut ctx, ctx.svc_iam.user_id, req.username, login_ip, device_id)!
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	sql db {
		update IamToken set token = token_jwt, updated_at = time.now(), expired_at = time.now().add_days(30)
		where user_id == ctx.svc_iam.user_id
	} or { return error('Failed: ${err}') }
	return RefreshTokenResp{
		expired_at: time.now().add_days(30).str()
		user_id:    ctx.svc_iam.user_id
		token_jwt:  token_jwt
	}
}

pub struct RefreshTokenReq {
	username string @[json: 'username']
}

pub struct RefreshTokenResp {
	expired_at string @[json: 'expired_at']
	user_id    string @[json: 'user_id']
	token_jwt  string @[json: 'token_jwt']
}
