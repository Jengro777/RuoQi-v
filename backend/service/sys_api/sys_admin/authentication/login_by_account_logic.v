module authentication

import veb
import log
import orm
import time
import rand
import x.json2 as json
import structs.schema_sys { SysToken, SysUser }
import common.api
import structs { Context }
import common.jwt
import common.captcha
import common.encrypt

// ----------------- Handler 层 -----------------
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

// ----------------- Application Service | Usecase 层 -----------------
pub fn login_by_account_usecase(mut ctx Context, req LoginByAccountReq) !LoginByAccountResp {
	// Domain 层校验参数与 captcha
	login_by_account_domain(mut ctx, req)!

	// Repository 层操作 DB 并生成 token
	return login_by_account_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn login_by_account_domain(mut ctx Context, req LoginByAccountReq) ! {
	if req.username == '' {
		return error('username is required')
	}
	if req.password == '' {
		return error('password is required')
	}
	if req.captcha_id == '' || req.captcha_text == '' {
		return error('captcha is required')
	}

	if !captcha.captcha_verify(req.captcha_id, req.captcha_text) {
		return error('Captcha error')
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
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 查询用户
	mut q_user := orm.new_query[SysUser](db)
	user_info := q_user.select('id', 'username', 'password', 'status')!
		.where('username = ?', req.username)!
		.limit(1)!
		.query()!

	if user_info.len == 0 {
		return error('UserName not exist')
	}

	if !encrypt.bcrypt_verify(req.password, user_info[0].password) {
		return error('UserName or Password error')
	}

	// 生成 token
	expired_at := time.now().add_days(30)
	token_jwt := token_jwt_generate(mut ctx, req)

	// 保存 token 到数据库
	tokens := SysToken{
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

	mut q_token := orm.new_query[SysToken](db)
	q_token.insert(tokens)!

	return LoginByAccountResp{
		expired_at: expired_at.str()
		user_id:    req.user_id
		token_jwt:  token_jwt
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn token_jwt_generate(mut ctx Context, req LoginByAccountReq) string {
	secret := ctx.get_custom_header('secret') or { '' }

	mut payload := jwt.JwtPayload{
		iss:       'v-admin'
		sub:       req.user_id
		exp:       time.now().add_days(30).unix()
		nbf:       time.now().unix()
		iat:       time.now().unix()
		jti:       rand.uuid_v4()
		roles:     ['admin', 'editor']
		client_ip: req.login_ip or { '' }
		device_id: req.device_id or { '' }
	}

	return jwt.jwt_generate(secret, payload)
}
