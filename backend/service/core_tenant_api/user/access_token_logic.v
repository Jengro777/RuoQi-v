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
@['/access_token'; post]
pub fn (app &User) access_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[AccessTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := access_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn access_token_usecase(mut ctx Context, req AccessTokenReq) !AccessTokenResp {
	// 参数校验
	access_token_domain(req)!

	// 写入数据库并生成 token
	return access_token_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn access_token_domain(req AccessTokenReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.device_id == '' {
		return error('device_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct AccessTokenReq {
	id        string @[json: 'id']
	status    u8     @[json: 'status']
	user_id   string @[json: 'user_id']
	username  string @[json: 'username']
	token     string @[json: 'token']
	source    string @[json: 'source']
	secret    string @[json: 'secret']
	device_id string @[json: 'device_id']
}

pub struct AccessTokenResp {
	token      string    @[json: 'token']
	expired_at time.Time @[json: 'expired_at']
}

// ----------------- Repository 层 -----------------
fn access_token_repo(mut ctx Context, req AccessTokenReq) !AccessTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now()
	expired_at := time_now.add_days(30).unix()

	// 查询 username
	username_rows := sql db {
		select from CoreUser where id == req.user_id limit 1
	} or { return error('Failed to execute SQL query: ${err}') }

	if username_rows.len == 0 {
		return error('User not found')
	}
	username := username_rows[0].str()

	// 生成 token
	token := access_token_jwt_generate(req, ctx, int(expired_at))

	// 写入数据库
	new_token := CoreToken{
		id:         rand.uuid_v7()
		status:     u8(0)
		user_id:    req.user_id
		username:   username
		token:      token
		source:     req.source
		expired_at: time.unix(expired_at)
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		insert new_token into CoreToken
	} or { return error('Failed to execute SQL query: ${err}') }

	return AccessTokenResp{
		token:      token
		expired_at: time.unix(expired_at)
	}
}

// ----------------- JWT 生成逻辑 -----------------
fn access_token_jwt_generate(req AccessTokenReq, ctx Context, expired_at int) string {
	time_now := time.now()
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: req.user_id
			exp: expired_at
			nbf: time_now.unix()
			iat: time_now.unix()
			jti: rand.uuid_v4()
		}
		role_ids:    ['', '']
		client_ip:   ctx.ip()
		device_id:   req.device_id
	}

	return jwt.auth_generate(ctx.config.jwt.secret, payload)
}
