module user

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_sys { SysToken }
import common.api
import structs { Context }
import common.jwt

// ----------------- Handler 层 -----------------
@['/refresh_token'; post]
pub fn (app &User) refresh_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RefreshTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := refresh_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn refresh_token_usecase(mut ctx Context, req RefreshTokenReq) !RefreshTokenResp {
	// 调用 Domain 层参数校验
	refresh_token_domain(req)!

	// 调用 Repository 层刷新 token
	return refresh_token(mut ctx, req)!
}

// ----------------- Domain 层 -----------------
fn refresh_token_domain(req RefreshTokenReq) ! {
	if req.user_id == '' {
		return error('user_id cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct RefreshTokenReq {
	token     string @[json: 'token']
	secret    string @[json: 'secret']
	user_id   string @[json: 'userId']
	source    string @[json: 'source']
	device_id string @[json: 'deviceId']
}

pub struct RefreshTokenResp {
	expired_at time.Time @[json: 'expiredAt']
	token      string    @[json: 'token']
}

// ----------------- AdapterRepository 层 -----------------
fn refresh_token(mut ctx Context, req RefreshTokenReq) !RefreshTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	time_now := time.now()
	expired_at_unix := time_now.add_days(30).unix()

	// 禁用用户现有 token
	sql db {
		update SysToken set status = 1 where user_id == req.user_id
	}!

	// 生成新的 token
	payload := jwt.JwtPayload{
		iss:       'ruoqi-v'
		sub:       req.user_id
		exp:       expired_at_unix
		nbf:       time_now.unix()
		iat:       time_now.unix()
		jti:       rand.uuid_v4()
		role_ids:  ['', '']
		client_ip: ctx.ip()
		device_id: req.device_id
	}
	token := jwt.jwt_generate(ctx.config.jwt.secret, payload)

	// 获取 username
	mut username_row := sql db {
		select username from schema_sys.SysUser where id == req.user_id limit 1
	}!

	username := if username_row.len > 0 { username_row[0].username } else { '' }

	// 写入数据库
	new_token := SysToken{
		id:         rand.uuid_v7()
		status:     u8(0)
		user_id:    req.user_id
		username:   username
		token:      token
		source:     req.source
		expired_at: time.unix(expired_at_unix)
		created_at: time_now
		updated_at: time_now
	}
	sql db {
		insert new_token into SysToken
	}!

	return RefreshTokenResp{
		expired_at: time.unix(expired_at_unix)
		token:      token
	}
}
