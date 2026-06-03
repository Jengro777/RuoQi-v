module authentication

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_core { CoreToken, CoreUser }
import common.api
import structs { Context }
import common.jwt
import common.captcha
import common.encrypt

// ----------------- Handler 层 -----------------
@['/authentication/login_by_account'; post]
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

// ----------------- Usecase 层 -----------------
pub fn login_by_account_usecase(mut ctx Context, req LoginByAccountReq) !LoginByAccountResp {
	// Domain 校验
	login_by_account_domain(req)!

	// Repository 执行登录逻辑
	return login_by_account_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn login_by_account_domain(req LoginByAccountReq) ! {
	if req.username == '' {
		return error('username is required')
	}
	if req.password == '' {
		return error('password is required')
	}
	if req.captcha_id == '' || req.captcha_text == '' {
		return error('captcha_id and captcha_text are required')
	}
}

// ----------------- DTO 层 -----------------
pub struct LoginByAccountReq {
	username     string  @[json: 'username']
	password     string  @[json: 'password']
	captcha_text string  @[json: 'captcha_text']
	captcha_id   string  @[json: 'captcha_id']
	status       u8      @[json: 'status']
	user_id      string  @[json: 'user_id']
	source       string  @[json: 'source']
	login_ip     ?string @[json: 'login_ip']
	device_id    ?string @[json: 'device_id']
}

pub struct LoginByAccountResp {
	expired_at string @[json: 'expired_at']
	user_id    string @[json: 'user_id']
	token_jwt  string @[json: 'token_jwt']
}

// ----------------- Repository 层 -----------------
fn login_by_account_repo(mut ctx Context, req LoginByAccountReq) !LoginByAccountResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 验证验证码
	if !captcha.captcha_verify(req.captcha_id, req.captcha_text) {
		return error('Captcha error')
	}

	// 查询用户
	user_info := sql db {
		select from CoreUser where username == req.username limit 1
	} or { return error('Failed to execute SQL query: ${err}') }

	if user_info.len == 0 {
		return error('UserName not exist')
	}
	if !encrypt.bcrypt_verify(req.password, user_info[0].password) {
		return error('UserName or Password error')
	}

	// 生成JWT
	expired_at := time.now().add_days(30)
	token_jwt := token_jwt_generate(mut ctx, req)

	// 写入Token
	tokens := CoreToken{
		id:         rand.uuid_v7()
		status:     req.status
		user_id:    req.user_id
		username:   req.username
		token:      token_jwt
		source:     req.source
		expired_at: expired_at
		created_at: time.now()
		updated_at: time.now()
	}

	sql db {
		upsert tokens into CoreToken
	} or { return error('Failed to execute SQL query: ${err}') }

	return LoginByAccountResp{
		expired_at: expired_at.str()
		user_id:    req.user_id
		token_jwt:  token_jwt
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn token_jwt_generate(mut ctx Context, req LoginByAccountReq) string {
	secret := ctx.config.jwt.secret

	mut payload := jwt.JwtPayload{
		iss:       'ruoqi-v'
		sub:       req.user_id
		exp:       time.now().add_days(30).unix()
		nbf:       time.now().unix()
		iat:       time.now().unix()
		jti:       rand.uuid_v4()
		role_ids:  ['admin', 'editor']
		client_ip: req.login_ip or { '' }
		device_id: req.device_id or { '' }
	}

	return jwt.jwt_generate(secret, payload)
}
