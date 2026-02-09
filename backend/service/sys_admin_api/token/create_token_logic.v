module token

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
@['/create'; post]
pub fn (app &Token) create_token_handler(mut ctx Context) veb.Result {
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
	user_id    string     @[json: 'userId']
	username   string     @[json: 'username']
	source     string     @[json: 'source']
	expired_at ?time.Time @[json: 'expiredAt']
	login_ip   string     @[json: 'loginIp']
	device_id  string     @[json: 'deviceId']
}

pub struct CreateTokenResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_token(mut ctx Context, req CreateTokenReq) !CreateTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	mut q := orm.new_query[SysToken](db)

	time_now := time.now()
	expired_at := time_now.add_days(30)
	token_jwt := token_jwt_generate(mut ctx, req) or { return error('Failed to generate token') }

	tokens := SysToken{
		id:         rand.uuid_v7()
		status:     req.status
		user_id:    req.user_id
		username:   req.username
		token:      token_jwt
		source:     req.source
		expired_at: expired_at
		created_at: time_now
		updated_at: time_now
	}

	q.insert(tokens)!

	return CreateTokenResp{
		msg: 'Token created successfully'
	}
}

fn find_user_roleids(mut ctx Context, user_id string) ![]string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// step2: 根据 user_id 查询 SysUser 表，判断是否为超级管理员
	sys_user := sql db {
		select from SysUser where id == user_id limit 1
	}!
	if sys_user.len != 1 {
		return error('User not found')
	}
	// 若用户为 root，则返回通配符 "*" 表示拥有所有权限
	if sys_user[0].is_root == 1 {
		log.debug('is_root: ${sys_user[0].is_root}, true')
		return ['*']
	}
	log.debug('is_root: ${sys_user[0].is_root}, false')

	// step3: 查询用户角色（一个用户可对应多个角色）
	sys_user_role := sql db {
		select from schema_sys.SysUserRole where user_id == user_id
	}!
	if sys_user_role.len < 1 {
		return error('User role not found')
	}
	mut user_role_id_list := sys_user_role.map(it.role_id)
	log.debug('role_id: ${user_role_id_list}')

	return user_role_id_list
}

// ----------------- JWT 生成逻辑 -----------------
fn token_jwt_generate(mut ctx Context, req CreateTokenReq) !string {
	secret := ctx.get_custom_header('secret') or { '' }

	user_role_ids := find_user_roleids(mut ctx, req.user_id) or {
		return error('Failed to find user role ids')
	}

	time_now := time.now()
	expired_at_unix := time_now.add_days(30).unix()
	mut payload := jwt.JwtPayload{
		iss:       'ruoqi-v'
		sub:       req.user_id
		exp:       expired_at_unix
		nbf:       time_now.unix()
		iat:       time_now.unix()
		jti:       rand.uuid_v4()
		role_ids:  user_role_ids
		client_ip: req.login_ip
		device_id: req.device_id
	}

	return jwt.jwt_generate(secret, payload)
}
