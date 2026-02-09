module user

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysUser, SysUserDepartment, SysUserPosition, SysUserRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/list'; post]
pub fn (app &User) user_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetUserListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_user_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_user_list_usecase(mut ctx Context, req GetUserListReq) !GetUserListResp {
	get_user_list_domain(req) or { return error('page and page_size must be positive integers') }
	return find_user_list(mut ctx, req)!
}

// ----------------- Domain 层 -----------------
fn get_user_list_domain(req GetUserListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct GetUserListReq {
	page          int = 1    @[json: 'page']
	page_size     int = 10    @[json: 'pageSize']
	department_id string @[json: 'departmentId']
	username      string @[json: 'username']
	nickname      string @[json: 'nickname']
	position_id   string @[json: 'positionId']
	mobile        string @[json: 'mobile']
	email         string @[json: 'email']
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
fn find_user_list(mut ctx Context, req GetUserListReq) !GetUserListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	offset_num := (req.page - 1) * req.page_size

	// 总数统计
	mut count := sql db {
		select count from SysUser
	}!

	mut q_user := orm.new_query[SysUser](db)
	mut query := q_user.select()!

	if req.username != '' {
		query = query.where('username = ?', req.username)!
	}
	if req.nickname != '' {
		query = query.where('nickname = ?', req.nickname)!
	}
	if req.position_id != '' {
		query = query.where('position_id = ?', req.position_id)!
	}
	if req.mobile != '' {
		query = query.where('mobile = ?', req.mobile)!
	}
	if req.email != '' {
		query = query.where('email = ?', req.email)!
	}

	// 处理 department_id 过滤 - 使用 JOIN 查询
	if req.department_id != '' {
		// 先查询该部门下的用户ID
		user_departments := sql db {
			select from SysUserDepartment where department_id == req.department_id
		}!

		if user_departments.len > 0 {
			// 使用 OR 条件构建查询
			mut first := true
			for ud in user_departments {
				if first {
					query = query.where('id = ?', ud.user_id)!
					first = false
				} else {
					query = query.or_where('id = ?', ud.user_id)!
				}
			}
		} else {
			// 如果没有用户在该部门，返回空结果
			return error('No users found in the specified department')
		}
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []GetUserList{}

	mut q_user_role := orm.new_query[SysUserRole](db)
	mut q_user_position := orm.new_query[SysUserPosition](db)
	mut q_user_department := orm.new_query[SysUserDepartment](db)

	for row in result {
		// 获取角色
		user_roles := q_user_role.select()!.where('user_id = ?', row.id)!.query()!
		mut role_ids := []string{}
		for r in user_roles {
			role_ids << r.role_id
		}

		// 获取职位
		user_positions := q_user_position.select()!.where('user_id = ?', row.id)!.query()!
		mut position_ids := []string{}
		for p in user_positions {
			position_ids << p.position_id
		}

		q_user_department.select()!.where('user_id = ?', row.id)!.query()!

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
