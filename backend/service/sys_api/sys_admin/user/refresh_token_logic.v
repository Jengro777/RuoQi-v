module user

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

// ----------------- Handler 层 -----------------
@['/refresh_token'; post]
pub fn(app &User)refresh_token_handler(mut ctx Context) veb.Result {
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
	if req.secret == '' {
		return error('secret cannot be empty')
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

// ----------------- AdapterRepository 层 -----------------
fn refresh_token(mut ctx Context, req RefreshTokenReq) !RefreshTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	time_now := time.now()
	expired_at_unix := time_now.add_days(30).unix()

	// 禁用用户现有 token
	mut q_token := orm.new_query[SysToken](db)
	q_token.set('status = ?', 1)!.where('user_id = ?', req.user_id)!.update()!

	// 生成新的 token
	payload := jwt.JwtPayload{
		iss:       'v-admin'
		sub:       req.user_id
		exp:       expired_at_unix
		nbf:       time_now.unix()
		iat:       time_now.unix()
		jti:       rand.uuid_v4()
		roles:     ['', '']
		client_ip: ctx.ip()
		device_id: req.device_id
	}
	token := jwt.jwt_generate(req.secret, payload)

	// 获取 username
	mut q_user := orm.new_query[SysUser](db)
	username_row := q_user.select('username')!.where('id = ?', req.user_id)!.limit(1)!.query()!
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
	q_token.insert(new_token)!

	return RefreshTokenResp{
		expired_at: time.unix(expired_at_unix)
		token:      token
	}
}
