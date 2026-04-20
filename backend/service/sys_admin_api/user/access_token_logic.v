/*
获取短期 token
*/

module user

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_sys { SysToken, SysUser }
import common.api
import common.jwt
import orm

// ----------------- Handler 层 -----------------
@['/access_token'; post]
pub fn (app &User) access_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[AccessTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	resp := access_token_usecase(mut ctx, req) or { return ctx.json(api.json_error_500(err.msg())) }

	return ctx.json(api.json_success_200(resp))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn access_token_usecase(mut ctx Context, req AccessTokenReq) !AccessTokenResp {
	// 1️⃣ 调用 Domain 层生成 token
	generate_access_token_domain(req)!

	// 2️⃣ 写入数据库 (Repository)
	new_token := create_token(mut ctx, req)!

	return new_token
}

// ----------------- Domain 层 -----------------
fn generate_access_token_domain(req AccessTokenReq) ! {
	if req.user_id == '' {
		return error('user_id cannot be empty')
	}
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct AccessTokenReq {
	id        string @[json: 'id']
	status    u8     @[json: 'status']
	user_id   string @[json: 'userId']
	username  string @[json: 'username']
	token     string @[json: 'token']
	source    string @[json: 'source']
	secret    string @[json: 'secret']
	login_ip  string @[json: 'loginIp']
	device_id string @[json: 'deviceId']
}

pub struct AccessTokenResp {
	token      string    @[json: 'token']
	expired_at time.Time @[json: 'expiredAt']
}

// ----------------- AdapterRepository 层 -----------------
fn create_token(mut ctx Context, req AccessTokenReq) !AccessTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') } }

	token_jwt := token_jwt_generate(mut ctx, req)!

	mut sys_token := orm.new_query[SysToken](db)

	time_now := time.now()
	expired_at := time_now.add_days(30)
	new_token := SysToken{
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
	sys_token.insert(new_token)!

	return AccessTokenResp{
		token:      token_jwt
		expired_at: expired_at
	}
}

fn find_user_roleids(mut ctx Context, user_id string) ![]string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

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
fn token_jwt_generate(mut ctx Context, req AccessTokenReq) !string {
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
