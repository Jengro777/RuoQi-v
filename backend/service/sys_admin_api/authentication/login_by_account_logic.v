module authentication

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
import common.captcha
import common.encrypt

// ----------------- Handler 层 -----------------
@['/login_by_account'; post]
pub fn (app &Authentication) login_by_account_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[LoginByAccountReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := login_by_account_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn login_by_account_usecase(mut ctx Context, req LoginByAccountReq) !LoginByAccountResp {
	// Domain 层校验参数与 captcha
	login_by_account_domain(mut ctx, req)!

	// Repository 层操作 DB 并生成 token
	return login_by_account_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn login_by_account_domain(mut ctx Context, req LoginByAccountReq) ! {
	if req.username == '' {
		return error('username is required')
	}
	if req.password == '' {
		return error('password is required')
	}
	if req.captcha_id == '' || req.captcha_text == '' {
		return error('captcha is required')
	}

	if !captcha.captcha_verify(req.captcha_id, req.captcha_text) {
		return error('Captcha error')
	}

	// // 检查SHA256 hex格式,前端不传输明文密码的时候使用
	// if !encrypt.is_sha256(req.password) {
	// 	return error('Invalid password format')
	// }
}

// ----------------- DTO 层 -----------------
pub struct LoginByAccountReq {
	username     string  @[json: 'username']
	password     string  @[json: 'password']
	captcha_text string  @[json: 'captcha']
	captcha_id   string  @[json: 'captchaId']
	source       ?string @[json: 'source']
	login_ip     ?string @[json: 'loginIp']
	device_id    ?string @[json: 'deviceId']
}

pub struct LoginByAccountResp {
	expired_at i64    @[json: 'expire']
	user_id    string @[json: 'userId']
	token_jwt  string @[json: 'token']
}

// ----------------- Repository 层 -----------------
fn login_by_account_repo(mut ctx Context, req LoginByAccountReq) !LoginByAccountResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 查询用户
	mut q_user := orm.new_query[SysUser](db)
	user_info := q_user.select('id', 'username', 'password', 'status')!
		.where('username = ?', req.username)!
		.limit(1)!
		.query()!

	if user_info.len == 0 {
		return error('UserName not exist')
	}

	// 先生成 SHA256 hex（加盐）
	client_sha := encrypt.sha256_hex(encrypt.client_salt + req.password)
	// bcrypt 验证
	if !encrypt.bcrypt_verify(client_sha, user_info[0].password) {
		return error('UserName or Password error')
	}

	// 生成 token
	expired_at := time.now().add_days(30)
	token_jwt := token_jwt_generate(mut ctx, req, user_info[0].id) or {
		return error('Failed to generate token')
	}

	// 保存 token 到数据库
	tokens := SysToken{
		id:         rand.uuid_v7()
		status:     0
		user_id:    user_info[0].id
		username:   user_info[0].username
		token:      token_jwt
		source:     'sys'
		expired_at: expired_at
		created_at: time.now()
		updated_at: time.now()
	}

	mut q_token := orm.new_query[SysToken](db)
	q_token.insert(tokens)!

	return LoginByAccountResp{
		expired_at: expired_at.unix()
		user_id:    user_info[0].id
		token_jwt:  token_jwt
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
fn token_jwt_generate(mut ctx Context, req LoginByAccountReq, user_id string) !string {
	secret := 'b17989d7-57d2-4ffa-88ab-f6987feb3eec'

	user_role_ids := find_user_roleids(mut ctx, user_id) or {
		return error('Failed to find user role ids')
	}

	mut payload := jwt.JwtPayload{
		iss:       'ruoqi-v'
		sub:       user_id
		exp:       time.now().add_days(30).unix()
		nbf:       time.now().unix()
		iat:       time.now().unix()
		jti:       rand.uuid_v4()
		role_ids:  user_role_ids
		client_ip: req.login_ip or { '' }
		device_id: req.device_id or { '' }
	}

	return jwt.jwt_generate(secret, payload)
}
