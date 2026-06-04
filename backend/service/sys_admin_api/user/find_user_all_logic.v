module user

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysUser, SysUserDepartment, SysUserPosition, SysUserRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
// @summary 获取用户列表
// @description 分页查询系统用户，支持按部门、用户名、昵称、手机号、邮箱筛选。
// @tag sys_admin_api/user
// @security bearerAuth
// @response 200 GetUserListResp 查询成功
// @response 400 api.ApiErrorResponse 请求参数错误
// @response 401 api.ApiErrorResponse 未登录
// @response 403 api.ApiErrorResponse 无权限
// @response 500 api.ApiErrorResponse 服务器内部错误
@['/all'; post]
pub fn (app &User) find_user_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetUserListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_user_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_user_all_usecase(mut ctx Context, req GetUserListReq) !GetUserListResp {
	find_user_all_domain(req) or { return error('page and page_size must be positive integers') }
	return find_user_all(mut ctx, req)!
}

// ----------------- Domain 层 -----------------
fn find_user_all_domain(req GetUserListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct GetUserListReq {
	// 页码，从 1 开始。
	// @example 1
	page int = 1 @[json: 'page']
	// 每页条数。
	// @example 10
	page_size int = 10 @[json: 'pageSize']
	// 部门 ID。
	// @example "dept_001"
	department_id string @[json: 'departmentId']
	// 用户名，可选。
	// @example "admin"
	username ?string @[json: 'username']
	// 昵称，可选。
	// @example "管理员"
	nickname ?string @[json: 'nickname']
	// 手机号，可选。
	// @example "13800000000"
	mobile ?string @[json: 'mobile']
	// 邮箱，可选。
	// @example "admin@example.com"
	email ?string @[json: 'email']
}

pub struct GetUserListResp {
	total int
	data  []GetUserList
}

pub struct GetUserList {
	id          string     @[json: 'id']
	username    string     @[json: 'username']
	nickname    string     @[json: 'nickname']
	mobile      string     @[json: 'mobile']
	email       string     @[json: 'email']
	role_ids    []string   @[json: 'roleIds']
	avatar      string     @[json: 'avatar']
	status      u8         @[json: 'status']
	description string     @[json: 'description']
	home_path   string     @[json: 'homePath']
	position_id []string   @[json: 'positionId']
	created_at  time.Time  @[json: 'createdAt']
	updated_at  time.Time  @[json: 'updatedAt']
	deleted_at  ?time.Time @[json: 'deletedAt']
}

// ----------------- AdapterRepository 层 -----------------
fn find_user_all(mut ctx Context, req GetUserListReq) !GetUserListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	offset_num := (req.page - 1) * req.page_size

	// 处理 department_id 过滤 - 获取用户ID列表
	mut user_ids := []string{}
	if req.department_id != '' {
		user_departments := sql db {
			select from SysUserDepartment where department_id == req.department_id
		}!

		if user_departments.len == 0 {
			// 部门下没有用户，返回空结果
			return GetUserListResp{
				total: 0
				data:  []
			}
		}

		// 提取用户ID
		for ud in user_departments {
			user_ids << ud.user_id
		}
	}

	// 构建动态查询条件
	wh_expr := {
		if username := req.username { username == username },
		if nickname := req.nickname { nickname == nickname },
		if mobile := req.mobile { mobile == mobile },
		if email := req.email { email == email },
		if user_ids.len > 0 { id in user_ids }
	}

	// 总数统计
	count := sql db {
		dynamic select count from SysUser where wh_expr
	}!

	// 查询分页数据
	result := sql db {
		dynamic select from SysUser where wh_expr limit req.page_size offset offset_num
	}!

	// 组装返回数据
	mut datalist := []GetUserList{}

	for row in result {
		// 获取角色
		user_roles := sql db {
			select from SysUserRole where user_id == row.id
		}!
		mut role_ids := []string{}
		for r in user_roles {
			role_ids << r.role_id
		}

		// 获取职位
		user_positions := sql db {
			select from SysUserPosition where user_id == row.id
		}!
		mut position_ids := []string{}
		for p in user_positions {
			position_ids << p.position_id
		}

		// 获取部门（如果需要）
		user_departments := sql db {
			select from SysUserDepartment where user_id == row.id
		}!
		mut department_ids := []string{}
		for d in user_departments {
			department_ids << d.department_id
		}

		datalist << GetUserList{
			id:          row.id
			username:    row.username
			nickname:    row.nickname
			mobile:      row.mobile or { '' }
			email:       row.email or { '' }
			role_ids:    role_ids
			position_id: position_ids
			avatar:      row.avatar or { '' }
			status:      row.status
			description: row.description or { '' }
			home_path:   row.home_path
			created_at:  row.created_at
			updated_at:  row.updated_at
			deleted_at:  row.deleted_at
		}
	}

	return GetUserListResp{
		total: count
		data:  datalist
	}
}
