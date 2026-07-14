module authentication

import veb
import log
import time
import rand
import json2 as json
import structs { Context }
import structs.schema_iam { IamToken, IamUser }
import common.api
import common.jwt
import service.iam_service.iam_api.token

// ═══ Handler ═══
@['/login_by_sms'; post]
pub fn (app &Authentication) login_by_sms_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[LoginBySmsReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := login_by_sms_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn login_by_sms_usecase(mut ctx Context, req LoginBySmsReq) !LoginBySmsResp {
	login_by_sms_domain(req)!
	return login_by_sms_repo(mut ctx, req)
}

// ═══ Domain ═══
fn login_by_sms_domain(req LoginBySmsReq) ! {
	if req.mobile == '' { return error('mobile is required') }
	if req.opt_num == '' || req.opt_token == '' { return error('OTP is required') }
}

// ═══ DTO ═══
pub struct LoginBySmsReq {
	status    u8     @[json: 'status']
	mobile    string @[json: 'mobile']
	opt_num   string @[json: 'optNum']
	opt_token string @[json: 'optToken']
	source    string @[json: 'source']
	login_ip  string @[json: 'loginIp']
	device_id string @[json: 'deviceId']
}

pub struct LoginBySmsResp {
	expired_at string @[json: 'expire']
	user_id    string @[json: 'userId']
	token_jwt  string @[json: 'tokenJwt']
}

// ═══ Repository ═══
fn login_by_sms_repo(mut ctx Context, req LoginBySmsReq) !LoginBySmsResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	if !jwt.opt_verify(req.opt_token, req.opt_num) { return error('OTP error') }
	user_info := sql db {
		select id, username, mobile, status from IamUser where mobile == req.mobile limit 1
	} or { return error('Failed: ${err}') }
	if user_info.len == 0 { return error('mobile not exist') }
	expired_at := time.now().add_days(30)
	token_jwt := token.generate_iam_token(mut ctx, user_info[0].id, user_info[0].username,
		req.login_ip, req.device_id) or { return error('Failed to generate token') }
	t := IamToken{
		id:         rand.uuid_v7()
		status:     req.status
		user_id:    user_info[0].id
		username:   user_info[0].username
		token:      token_jwt
		source:     req.source
		expired_at: expired_at
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		upsert t into IamToken
	} or { return error('Failed: ${err}') }
	return LoginBySmsResp{
		expired_at: expired_at.str()
		user_id:    user_info[0].id
		token_jwt:  token_jwt
	}
}
