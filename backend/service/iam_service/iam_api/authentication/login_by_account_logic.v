module authentication

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import service.iam_service.iam_api.token
import structs.schema_iam { IamToken, IamUser }
import common.api
import common.jwt
import common.encrypt

@['/login_by_account'; post]
pub fn (app &Authentication) login_by_account_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[LoginByAccountReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := login_by_account_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn login_by_account_usecase(mut ctx Context, req LoginByAccountReq) !LoginByAccountResp {
	if req.username == '' { return error('username is required') }
	if req.password == '' { return error('password is required') }
	if req.captcha_id == '' || req.captcha_text == '' { return error('captcha error') }
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	if !jwt.captcha_verify(req.captcha_id, req.captcha_text) { return error('Captcha error') }
	user_info := sql db {
		select from IamUser where username == req.username limit 1
	} or { return error('Failed: ${err}') }
	if user_info.len == 0 { return error('UserName not exist') }
	if !encrypt.bcrypt_verify(req.password, user_info[0].password) {
		return error('UserName or Password error')
	}
	expired_at := time.now().add_days(30)
	token_jwt := token.generate_iam_token(mut ctx, user_info[0].id, req.username, req.login_ip or {
		''
	}, req.device_id or { '' }) or { return error('Failed to generate token') }
	t := IamToken{
		id:         rand.uuid_v7()
		status:     req.status
		user_id:    user_info[0].id
		username:   req.username
		token:      token_jwt
		source:     req.source
		expired_at: expired_at
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		upsert t into IamToken
	} or { return error('Failed: ${err}') }
	return LoginByAccountResp{
		expired_at: expired_at.str()
		user_id:    user_info[0].id
		token_jwt:  token_jwt
	}
}

pub struct LoginByAccountReq {
	username     string  @[json: 'username']
	password     string  @[json: 'password']
	captcha_text string  @[json: 'captcha_text']
	captcha_id   string  @[json: 'captcha_id']
	status       u8      @[json: 'status']
	source       string  @[json: 'source']
	login_ip     ?string @[json: 'login_ip']
	device_id    ?string @[json: 'device_id']
}

pub struct LoginByAccountResp {
	expired_at string @[json: 'expired_at']
	user_id    string @[json: 'user_id']
	token_jwt  string @[json: 'token_jwt']
}
