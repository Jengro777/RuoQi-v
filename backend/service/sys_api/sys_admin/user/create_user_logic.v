module user

import veb
import log
import time
import x.json2 as json
import rand
import structs { Context }
import structs.schema_sys { SysUser, SysUserPosition, SysUserRole }
import common.api
import common.encrypt
import orm

// ----------------- Handler 层 -----------------
@['/create_user'; post]
pub fn (app &User) create_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_user_usecase(mut ctx Context, req CreateUserReq) !CreateUserResp {
	// 调用 Domain 层逻辑：生成 ID、密码加密等
	user_id, password_hash := create_user_domain(req)!

	// 调用 Repository 保存用户、角色、职位
	create_user(mut ctx, req, user_id, password_hash)!

	return CreateUserResp{
		msg: 'User created successfully'
	}
}

// ----------------- Domain 层 -----------------
fn create_user_domain(req CreateUserReq) !(string, string) {
	if req.username == '' || req.password == '' {
		return error('username and password cannot be empty')
	}

	user_id := rand.uuid_v7()
	password_hash := encrypt.bcrypt_hash(req.password) or {
		return error('Failed to hash password: ${err}')
	}

	return user_id, password_hash
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct CreateUserReq {
	avatar       string    @[json: 'avatar']
	description  string    @[json: 'description']
	mobile       string    @[json: 'mobile']
	email        string    @[json: 'email']
	home_path    string    @[json: 'home_path']
	nickname     string    @[json: 'nickname']
	password     string    @[json: 'password']
	status       u8        @[json: 'status']
	username     string    @[json: 'username']
	position_ids []string  @[json: 'position_ids']
	role_ids     []string  @[json: 'role_ids']
	created_at   time.Time @[json: 'created_at']
	updated_at   time.Time @[json: 'updated_at']
}

pub struct CreateUserResp {
	msg string @[json: 'msg']
}

// ----------------- AdapterRepository 层 -----------------
fn create_user(mut ctx Context, req CreateUserReq, user_id string, password_hash string) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 构建 SysUser 对象
	user := SysUser{
		id:          user_id
		avatar:      req.avatar
		description: req.description
		email:       req.email
		home_path:   req.home_path
		mobile:      req.mobile
		nickname:    req.nickname
		password:    password_hash
		status:      req.status
		username:    req.username
		created_at:  req.created_at
		updated_at:  req.updated_at
	}

	// 构建用户职位
	mut user_positions := []SysUserPosition{cap: req.position_ids.len}
	for pos_id in req.position_ids {
		user_positions << SysUserPosition{
			user_id:     user_id
			position_id: pos_id
		}
	}

	// 构建用户角色
	mut user_roles := []SysUserRole{cap: req.role_ids.len}
	for role_id in req.role_ids {
		user_roles << SysUserRole{
			user_id: user_id
			role_id: role_id
		}
	}

	// 插入数据库
	mut q_user := orm.new_query[SysUser](db)
	mut q_user_pos := orm.new_query[SysUserPosition](db)
	mut q_user_role := orm.new_query[SysUserRole](db)

	q_user.insert(user)!
	q_user_pos.insert_many(user_positions)!
	q_user_role.insert_many(user_roles)!
}
