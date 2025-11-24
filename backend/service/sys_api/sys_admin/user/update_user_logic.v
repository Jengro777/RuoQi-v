module user

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysUser, SysUserPosition, SysUserRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update_user'; post]
pub fn(app &User)update_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_user_usecase(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	// 调用 Domain 层进行参数校验
	update_user_domain(req)!

	// 调用 Repository 层更新用户信息
	return update_user(mut ctx, req)!
}

// ----------------- Domain 层 -----------------
fn update_user_domain(req UpdateUserReq) ! {
	if req.user_id == '' {
		return error('user_id cannot be empty')
	}
	if req.username == '' {
		return error('username cannot be empty')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateUserReq {
	user_id       string    @[json: 'user_id']
	position_ids  []string  @[json: 'position_ids']
	role_ids      []string  @[json: 'role_ids']
	avatar        string    @[json: 'avatar']
	department_id string    @[json: 'department_id']
	description   string    @[json: 'description']
	email         string    @[json: 'email']
	home_path     string    @[json: 'home_path']
	mobile        string    @[json: 'mobile']
	nickname      string    @[json: 'nickname']
	password      string    @[json: 'password']
	status        u8        @[default: 0; json: 'status']
	username      string    @[json: 'username']
	updated_at    time.Time @[json: 'updated_at']
}

pub struct UpdateUserResp {
	msg string @[json: 'msg']
}

// ----------------- AdapterRepository 层 -----------------
fn update_user(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	// 构建用户职位关系
	mut user_positions := []SysUserPosition{cap: req.position_ids.len}
	for pos_id in req.position_ids {
		user_positions << SysUserPosition{
			user_id:     req.user_id
			position_id: pos_id
		}
	}

	// 构建用户角色关系
	mut user_roles := []SysUserRole{cap: req.role_ids.len}
	for role_id in req.role_ids {
		user_roles << SysUserRole{
			user_id: req.user_id
			role_id: role_id
		}
	}

	// 更新用户表
	mut q_user := orm.new_query[SysUser](db)

	q_user.set('avatar = ?', req.avatar)!
		.set('email = ?', req.email)!
		.set('mobile = ?', req.mobile)!
		.set('nickname = ?', req.nickname)!
		.set('department_id = ?', req.department_id)!
		.set('description = ?', req.description)!
		.set('home_path = ?', req.home_path)!
		.set('password = ?', req.password)!
		.set('status = ?', req.status)!
		.set('username = ?', req.username)!
		.set('updated_at = ?', req.updated_at)!
		.where('id = ?', req.user_id)!
		.update()!

	// 更新用户职位关系
	mut q_user_pos := orm.new_query[SysUserPosition](db)
	q_user_pos.delete()!.where('user_id = ?', req.user_id)!
	q_user_pos.insert_many(user_positions)!

	// 更新用户角色关系
	mut q_user_role := orm.new_query[SysUserRole](db)
	q_user_role.delete()!.where('user_id = ?', req.user_id)!
	q_user_role.insert_many(user_roles)!

	return UpdateUserResp{
		msg: 'User updated successfully'
	}
}
