module authentication

import veb
import log
import time
import rand
import json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api
import common.crypt
import common.encrypt

// ═══ Handler ═══
@['/signup_by_sms'; post]
pub fn (app &Authentication) signup_by_sms_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[SignupBySmsReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := signup_by_sms_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn signup_by_sms_usecase(mut ctx Context, req SignupBySmsReq) !SignupBySmsResp {
	signup_by_sms_domain(req)!
	return signup_by_sms_repo(mut ctx, req)
}

// ═══ Domain ═══
fn signup_by_sms_domain(req SignupBySmsReq) ! {
	if req.mobile == '' { return error('mobile is required') }
	if req.password == '' { return error('password is required') }
	if req.opt_num == '' || req.opt_token == '' { return error('OTP is required') }
}

// ═══ DTO ═══
pub struct SignupBySmsReq {
	username  string @[json: 'username']
	password  string @[json: 'password']
	nickname  string @[json: 'nickname']
	mobile    string @[json: 'mobile']
	opt_num   string @[json: 'optNum']
	opt_token string @[json: 'optToken']
}

pub struct SignupBySmsResp {
	user_id string @[json: 'user_id']
	msg     string @[json: 'msg']
}

// ═══ Repository ═══
fn signup_by_sms_repo(mut ctx Context, req SignupBySmsReq) !SignupBySmsResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	if !crypt.opt_verify(ctx.config.jwt.secret, req.opt_token, req.opt_num) {
		return error('OTP error')
	}
	dup := sql db {
		select from IamUser where mobile == req.mobile limit 1
	} or { return error('Failed: ${err}') }
	if dup.len > 0 { return error('mobile already registered') }
	user_id := rand.uuid_v7()
	password_hash := encrypt.bcrypt_hash(req.password) or {
		return error('Failed to hash password')
	}
	user := IamUser{
		id:         user_id
		username:   req.username
		password:   password_hash
		nickname:   req.nickname
		mobile:     req.mobile
		home_path:  '"/dashboard"'
		status:     0
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert user into IamUser
	} or { return error('Failed to create user: ${err}') }
	return SignupBySmsResp{
		user_id: user_id
		msg:     'Signup successful'
	}
}
