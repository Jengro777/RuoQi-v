module user

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysUser, SysUserDepartment, SysUserPosition, SysUserRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &User) update_user_handler(mut ctx Context) veb.Result {
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
}

// ----------------- DTO 层 -----------------
pub struct UpdateUserReq {
	user_id       string   @[json: 'id']
	position_ids  []string @[json: 'positionIds']
	role_ids      []string @[json: 'roleIds']
	avatar        ?string  @[json: 'avatar']
	department_id ?string  @[json: 'departmentId']
	description   ?string  @[json: 'description']
	email         ?string  @[json: 'email']
	home_path     ?string  @[json: 'homePath']
	mobile        ?string  @[json: 'mobile']
	nickname      ?string  @[json: 'nickname']
	password      ?string  @[json: 'password']
	status        ?u8      @[default: 0; json: 'status']
	username      ?string  @[json: 'username']
}

pub struct UpdateUserResp {
	msg string @[json: 'msg']
}

// ----------------- AdapterRepository 层 -----------------
fn update_user(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
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

	if avatar := req.avatar {
		q_user.set('avatar = ?', avatar)!
	}
	if email := req.email {
		q_user.set('email = ?', email)!
	}
	if mobile := req.mobile {
		q_user.set('mobile = ?', mobile)!
	}
	if nickname := req.nickname {
		q_user.set('nickname = ?', nickname)!
	}
	// 移除 department_id 设置，因为它不在 SysUser 表中
	// if department_id := req.department_id {
	//     q_user.set('department_id = ?', department_id)!
	// }
	if description := req.description {
		q_user.set('description = ?', description)!
	}
	if home_path := req.home_path {
		q_user.set('home_path = ?', home_path)!
	}
	if password := req.password {
		q_user.set('password = ?', password)!
	}
	if status := req.status {
		q_user.set('status = ?', status)!
	}
	if username := req.username {
		q_user.set('username = ?', username)!
	}

	q_user.where('id = ?', req.user_id)!
		.update()!

	// 更新用户职位关系 - 修正链式调用顺序
	mut q_user_pos := orm.new_query[SysUserPosition](db)

	q_user_pos.where('user_id = ?', req.user_id)!
		.delete()!
	if user_positions.len > 0 {
		q_user_pos.insert_many(user_positions)!
	}

	// 更新用户角色关系
	mut q_user_role := orm.new_query[SysUserRole](db)

	q_user_role.where('user_id = ?', req.user_id)!
		.delete()!
	if user_roles.len > 0 {
		q_user_role.insert_many(user_roles)!
	}

	// 处理部门关联（新增）
	if department_id := req.department_id {
		mut q_user_dep := orm.new_query[SysUserDepartment](db)

		q_user_dep.where('user_id = ?', req.user_id)!
			.delete()!
		if department_id != '' {
			user_dep := SysUserDepartment{
				user_id:       req.user_id
				department_id: department_id
			}
			q_user_dep.insert(user_dep)!
		}
	}

	return UpdateUserResp{
		msg: 'User updated successfully'
	}
}
