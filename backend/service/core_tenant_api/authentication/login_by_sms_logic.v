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
import common.opt

// ----------------- Handler 层 -----------------
@['/login_by_sms'; post]
pub fn (app &Authentication) login_by_sms_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[LoginBySMSReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := login_by_sms_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn login_by_sms_usecase(mut ctx Context, req LoginBySMSReq) !LoginBySMSResp {
	// 参数校验
	login_by_sms_domain(req)!

	// DB 操作 + Token 生成
	return login_by_sms_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn login_by_sms_domain(req LoginBySMSReq) ! {
	if req.phone_num == '' {
		return error('phone_num is required')
	}
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.opt_num == '' || req.opt_token == '' {
		return error('opt_num and opt_token are required')
	}
}

// ----------------- DTO 层 -----------------
pub struct LoginBySMSReq {
	status    u8     @[json: 'status']
	phone_num string @[json: 'phone_num']
	opt_num   string @[json: 'opt_num']
	opt_token string @[json: 'opt_token']
	user_id   string @[json: 'user_id']
	source    string @[json: 'source']
	login_ip  string @[json: 'login_ip']
	device_id string @[json: 'device_id']
}

pub struct LoginBySMSResp {
	expired_at string @[json: 'expired_at']
	user_id    string @[json: 'user_id']
	token_jwt  string @[json: 'token_jwt']
}

// ----------------- Repository 层 -----------------
fn login_by_sms_repo(mut ctx Context, req LoginBySMSReq) !LoginBySMSResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 验证验证码
	if !opt.opt_verify(req.opt_token, req.opt_num) {
		return error('Captcha error')
	}

	// 查询用户
	user_info := sql db {
		select from CoreUser where phone == req.phone_num limit 1
	} or { return error('Failed to execute SQL query: ${err}') }

	if user_info.len == 0 {
		return error('mobile not exist')
	}

	// 生成 JWT Token
	expired_at := time.now().add_days(30)
	token_jwt := sms_token_jwt_generate(mut ctx, req)

	// 插入 Token
	token_record := CoreToken{
		id:         rand.uuid_v7()
		status:     req.status
		user_id:    req.user_id
		username:   user_info[0].username
		token:      token_jwt
		source:     req.source
		expired_at: expired_at
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		upsert token_record into CoreToken
	} or { return error('Failed to execute SQL query: ${err}') }

	return LoginBySMSResp{
		expired_at: expired_at.str()
		user_id:    req.user_id
		token_jwt:  token_jwt
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn sms_token_jwt_generate(mut ctx Context, req LoginBySMSReq) string {
	secret := ctx.get_custom_header('secret') or { '' }

	mut payload := jwt.JwtPayload{
		iss:       'ruoqi-v'
		sub:       req.user_id
		exp:       time.now().add_days(30).unix()
		nbf:       time.now().unix()
		iat:       time.now().unix()
		jti:       rand.uuid_v4()
		role_ids:  ['admin', 'editor']
		client_ip: req.login_ip
		device_id: req.device_id
	}

	return jwt.jwt_generate(secret, payload)
}
