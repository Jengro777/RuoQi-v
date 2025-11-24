module token

import veb
import log
import orm
import time
import rand
import x.json2 as json
import structs.schema_sys { SysToken }
import common.api
import structs { Context }
import common.jwt

// ----------------- Handler 层 -----------------
@['/token/create'; post]
pub fn(app &Token)token_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := create_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_token_usecase(mut ctx Context, req CreateTokenReq) !CreateTokenResp {
	// Domain 校验层
	create_token_domain(req)!

	// Repository 写入数据库
	return create_token(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_token_domain(req CreateTokenReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.username == '' {
		return error('username is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateTokenReq {
	status     u8         @[json: 'status']
	user_id    string     @[json: 'user_id']
	username   string     @[json: 'username']
	source     string     @[json: 'source']
	expired_at ?time.Time @[json: 'expired_at']
	created_at ?time.Time @[json: 'created_at']
	updated_at ?time.Time @[json: 'updated_at']
	login_ip   string     @[json: 'login_ip']
	device_id  string     @[json: 'device_id']
}

pub struct CreateTokenResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_token(mut ctx Context, req CreateTokenReq) !CreateTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysToken](db)

	tokens := SysToken{
		id:         rand.uuid_v7()
		status:     req.status
		user_id:    req.user_id
		username:   req.username
		token:      token_jwt_generate(mut ctx, req)
		source:     req.source
		expired_at: req.expired_at or { time.now().add_days(30) }
		created_at: req.created_at or { time.now() }
		updated_at: req.updated_at or { time.now() }
	}

	q.insert(tokens)!

	return CreateTokenResp{
		msg: 'Token created successfully'
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn token_jwt_generate(mut ctx Context, req CreateTokenReq) string {
	secret := ctx.get_custom_header('secret') or { '' }

	mut payload := jwt.JwtPayload{
		iss:       'v-admin'
		sub:       req.user_id
		exp:       time.now().add_days(30).unix()
		nbf:       time.now().unix()
		iat:       time.now().unix()
		jti:       rand.uuid_v4()
		roles:     ['admin', 'editor']
		client_ip: req.login_ip
		device_id: req.device_id
	}

	return jwt.jwt_generate(secret, payload)
}
