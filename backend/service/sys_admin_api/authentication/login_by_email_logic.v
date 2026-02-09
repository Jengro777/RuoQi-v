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
import common.opt

// ----------------- Handler 层 -----------------
@['/login_by_email'; post]
pub fn (app &Authentication) login_by_email_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[LoginByEmailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := login_by_email_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn login_by_email_usecase(mut ctx Context, req LoginByEmailReq) !LoginByEmailResp {
	// Domain 校验
	login_by_email_domain(req)!

	// Repository 执行数据库操作
	return login_by_email_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn login_by_email_domain(req LoginByEmailReq) ! {
	if req.email == '' {
		return error('email is required')
	}
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.opt_num == '' || req.opt_token == '' {
		return error('captcha is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct LoginByEmailReq {
	status    u8     @[json: 'status']
	email     string @[json: 'email']
	opt_num   string @[json: 'optNum']
	opt_token string @[json: 'optToken']
	user_id   string @[json: 'userId']
	source    string @[json: 'source']
	login_ip  string @[json: 'loginIp']
	device_id string @[json: 'deviceId']
}

pub struct LoginByEmailResp {
	expired_at string @[json: 'expire']
	user_id    string @[json: 'userId']
	token_jwt  string @[json: 'tokenJwt']
}

// ----------------- Repository 层 -----------------
fn login_by_email_repo(mut ctx Context, req LoginByEmailReq) !LoginByEmailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	if !opt.opt_verify(req.opt_token, req.opt_num) {
		return error('Captcha error')
	}

	mut q_user := orm.new_query[SysUser](db)
	user_info := q_user.select('id', 'username', 'email', 'status')!
		.where('email = ?', req.email)!
		.limit(1)!
		.query()!

	if user_info.len == 0 {
		return error('email not exist')
	}

	expired_at := time.now().add_days(30)
	token_jwt := email_token_jwt_generate(mut ctx, req, user_info[0].username)

	// 插入 token
	tokens := SysToken{
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

	mut q_token := orm.new_query[SysToken](db)
	q_token.insert(tokens)!

	return LoginByEmailResp{
		expired_at: expired_at.str()
		user_id:    req.user_id
		token_jwt:  token_jwt
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn email_token_jwt_generate(mut ctx Context, req LoginByEmailReq, username string) string {
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
