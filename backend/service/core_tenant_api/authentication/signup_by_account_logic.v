module authentication

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_core { CoreUser }
import common.api
import structs { Context }
import common.encrypt

// ----------------- Handler 层 -----------------
@['/user/create'; post]
pub fn (app &Authentication) create_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_user_usecase(mut ctx Context, req CreateUserReq) !CreateUserResp {
	// Domain 参数校验
	create_user_domain(req)!

	// Repository 写入数据库
	return create_user_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_user_domain(req CreateUserReq) ! {
	if req.username == '' {
		return error('username is required')
	}
	if req.password == '' {
		return error('password is required')
	}
	if req.nickname == '' {
		return error('nickname is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct CreateUserReq {
	avatar      string     @[json: 'avatar']
	description string     @[json: 'description']
	email       string     @[json: 'email']
	home_path   string     @[json: 'home_path']
	nickname    string     @[json: 'nickname']
	password    string     @[json: 'password']
	status      u8         @[json: 'status']
	username    string     @[json: 'username']
	created_at  ?time.Time @[json: 'created_at']
	updated_at  ?time.Time @[json: 'updated_at']
}

pub struct CreateUserResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_user_repo(mut ctx Context, req CreateUserReq) !CreateUserResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	user_id := rand.uuid_v7()
	password_hash := encrypt.bcrypt_hash(req.password) or {
		return error('Failed to hash password: ${err}')
	}

	user := CoreUser{
		id:          user_id
		avatar:      req.avatar
		description: req.description
		email:       req.email
		home_path:   req.home_path
		nickname:    req.nickname
		password:    password_hash
		status:      req.status
		username:    req.username
		created_at:  req.created_at or { time.now() }
		updated_at:  req.updated_at or { time.now() }
	}

	sql db {
		upsert user into CoreUser
	} or { return error('Failed to execute SQL query: ${err}') }

	return CreateUserResp{
		msg: 'User created successfully'
	}
}
