module authentication

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api
import common.jwt
import common.encrypt

@['/signup_by_account'; post]
pub fn (app &Authentication) signup_by_account_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[SignupByAccountReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := signup_by_account_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn signup_by_account_usecase(mut ctx Context, req SignupByAccountReq) !SignupByAccountResp {
	if req.username == '' { return error('username is required') }
	if req.password == '' { return error('password is required') }
	if req.captcha_id == '' || req.captcha_text == '' { return error('captcha is required') }
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	if !jwt.captcha_verify(req.captcha_id, req.captcha_text) { return error('Captcha error') }
	dup := sql db {
		select from IamUser where username == req.username limit 1
	} or { return error('Failed: ${err}') }
	if dup.len > 0 { return error('username already exists') }
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
		mobile:     req.mobile
		home_path:  '"/dashboard"'
		status:     0
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert user into IamUser
	} or { return error('Failed to create user: ${err}') }
	return SignupByAccountResp{
		user_id: user_id
		msg:     'Signup successful'
	}
}

pub struct SignupByAccountReq {
	username     string @[json: 'username']
	password     string @[json: 'password']
	nickname     string @[json: 'nickname']
	email        string @[json: 'email']
	mobile       string @[json: 'mobile']
	captcha_text string @[json: 'captcha_text']
	captcha_id   string @[json: 'captcha_id']
}

pub struct SignupByAccountResp {
	user_id string @[json: 'user_id']
	msg     string @[json: 'msg']
}
