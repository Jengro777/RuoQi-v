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
@['/signup_by_email'; post]
pub fn (app &Authentication) signup_by_email_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[SignupByEmailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := signup_by_email_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn signup_by_email_usecase(mut ctx Context, req SignupByEmailReq) !SignupByEmailResp {
	signup_by_email_domain(req)!
	return signup_by_email_repo(mut ctx, req)
}

// ═══ Domain ═══
fn signup_by_email_domain(req SignupByEmailReq) ! {
	if req.email == '' { return error('email is required') }
	if req.password == '' { return error('password is required') }
	if req.opt_num == '' || req.opt_token == '' { return error('OTP is required') }
}

// ═══ DTO ═══
pub struct SignupByEmailReq {
	username  string @[json: 'username']
	password  string @[json: 'password']
	nickname  string @[json: 'nickname']
	email     string @[json: 'email']
	opt_num   string @[json: 'optNum']
	opt_token string @[json: 'optToken']
}

pub struct SignupByEmailResp {
	user_id string @[json: 'user_id']
	msg     string @[json: 'msg']
}

// ═══ Repository ═══
fn signup_by_email_repo(mut ctx Context, req SignupByEmailReq) !SignupByEmailResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	if !crypt.opt_verify(ctx.config.jwt.secret, req.opt_token, req.opt_num) {
		return error('OTP error')
	}
	dup := sql db {
		select from IamUser where email == req.email limit 1
	} or { return error('Failed: ${err}') }
	if dup.len > 0 { return error('email already registered') }
	user_id := rand.uuid_v7()
	password_hash := encrypt.bcrypt_hash(req.password) or {
		return error('Failed to hash password')
	}
	user := IamUser{
		id:         user_id
		username:   req.username
		password:   password_hash
		nickname:   req.nickname
		email:      req.email
		home_path:  '"/dashboard"'
		status:     0
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert user into IamUser
	} or { return error('Failed to create user: ${err}') }
	return SignupByEmailResp{
		user_id: user_id
		msg:     'Signup successful'
	}
}
