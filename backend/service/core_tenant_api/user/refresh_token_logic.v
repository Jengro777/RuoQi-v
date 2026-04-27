module user

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_core { CoreToken, CoreUser }
import common.api
import structs { Context }
import common.jwt

// ----------------- Handler 层 -----------------
@['/token/refresh'; post]
pub fn (app &User) refresh_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RefreshTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := refresh_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn refresh_token_usecase(mut ctx Context, req RefreshTokenReq) !RefreshTokenResp {
	// 参数校验
	refresh_token_domain(req)!

	// 执行 Repository 层
	return refresh_token_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn refresh_token_domain(req RefreshTokenReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.secret == '' {
		return error('secret is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct RefreshTokenReq {
	token     string @[json: 'token']
	secret    string @[json: 'secret']
	user_id   string @[json: 'user_id']
	source    string @[json: 'source']
	device_id string @[json: 'device_id']
}

pub struct RefreshTokenResp {
	expired_at time.Time @[json: 'expired_at']
	token      string    @[json: 'token']
}

// ----------------- Repository 层 -----------------
fn refresh_token_repo(mut ctx Context, req RefreshTokenReq) !RefreshTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now()
	expired_at_unix := time_now.add_days(30).unix()

	// 禁用当前用户所有 token
	sql db {
		dynamic update CoreToken set {
		status == 1
	} where user_id == req.user_id
	} or { return error('Failed to execute SQL query: ${err}') }

	// 获取用户名
	username_rows := sql db {
		select from CoreUser where id == req.user_id limit 1
	} or { return error('Failed to execute SQL query: ${err}') }
	username := if username_rows.len > 0 { username_rows[0].str() } else { '' }

	// 生成新的 JWT
	new_jwt := generate_jwt(mut ctx, req, time_now)

	// 写入数据库
	new_token := CoreToken{
		id:         rand.uuid_v7()
		status:     u8(0)
		user_id:    req.user_id
		username:   username
		token:      new_jwt
		source:     req.source
		expired_at: time.unix(expired_at_unix)
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		upsert new_token into CoreToken
	}!

	return RefreshTokenResp{
		expired_at: time.unix(expired_at_unix)
		token:      new_jwt
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn generate_jwt(mut ctx Context, req RefreshTokenReq, now time.Time) string {
	payload := jwt.JwtPayload{
		iss:       'ruoqi-v'
		sub:       req.user_id
		exp:       now.add_days(30).unix()
		nbf:       now.unix()
		iat:       now.unix()
		jti:       rand.uuid_v4()
		role_ids:  ['', '']
		client_ip: ctx.ip()
		device_id: req.device_id
	}
	return jwt.jwt_generate(req.secret, payload)
}
