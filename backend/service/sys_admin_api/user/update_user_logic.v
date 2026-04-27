module user

import veb
import log
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
	up_expr := {
		if avatar := req.avatar { avatar == avatar },
		if email := req.email { email == email },
		if mobile := req.mobile { mobile == mobile },
		if nickname := req.nickname { nickname == nickname },
		if description := req.description { description == description },
		if home_path := req.home_path { home_path == home_path },
		if password := req.password { password == password },
		if status := req.status { status == status },
		if username := req.username { username == username }
	}
	sql db {
		dynamic update SysUser set up_expr where id == req.user_id
	}!

	// 更新用户职位关系 - 修正链式调用顺序
	sql db {
		delete from SysUserPosition where user_id == req.user_id
	}!
	if user_positions.len > 0 {
		for up in user_positions {
			sql db {
				insert up into SysUserPosition
			}!
		}
	}

	// 更新用户角色关系
	sql db {
		delete from SysUserRole where user_id == req.user_id
	}!
	if user_roles.len > 0 {
		for ur in user_roles {
			sql db {
				insert ur into SysUserRole
			}!
		}
	}

	// 处理部门关联（新增）
	if department_id := req.department_id {
		sql db {
			delete from SysUserDepartment where user_id == req.user_id
		}!
		if department_id != '' {
			user_dep := SysUserDepartment{
				user_id:       req.user_id
				department_id: department_id
			}
			sql db {
				insert user_dep into SysUserDepartment
			}!
		}
	}

	return UpdateUserResp{
		msg: 'User updated successfully'
	}
}
