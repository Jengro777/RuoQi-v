module user

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_core { CoreRoleTenantMember, CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/user/list'; post]
pub fn (app &User)user_list_handler(mut ctx Context) veb.Result {
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
	get_user_list_domain(req)!
	return find_user_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_user_list_domain(req GetUserListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetUserListReq {
	page        int    @[json: 'page']
	page_size   int    @[json: 'page_size']
	username    string @[json: 'username']
	nickname    string @[json: 'nickname']
	position_id int    @[json: 'position_id']
	mobile      string @[json: 'mobile']
	email       string @[json: 'email']
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
	role_ids    []string   @[json: 'role_ids']
	avatar      string     @[json: 'avatar']
	status      u8         @[json: 'status']
	description string     @[json: 'description']
	home_path   string     @[json: 'home_path']
	created_at  time.Time  @[json: 'created_at']
	updated_at  time.Time  @[json: 'updated_at']
	deleted_at  ?time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn find_user_list_repo(mut ctx Context, req GetUserListReq) !GetUserListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	offset_num := (req.page - 1) * req.page_size

	mut count := sql db {
		select count from CoreUser
	}!

	mut core_user := orm.new_query[CoreUser](db)
	mut core_user_role := orm.new_query[CoreRoleTenantMember](db)

	mut query := core_user.select()!
	if req.username != '' {
		query = query.where('username = ?', req.username)!
	}
	if req.nickname != '' {
		query = query.where('nickname = ?', req.nickname)!
	}
	if req.position_id != 0 {
		query = query.where('position_id = ?', req.position_id)!
	}
	if req.mobile != '' {
		query = query.where('mobile = ?', req.mobile)!
	}
	if req.email != '' {
		query = query.where('email = ?', req.email)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []GetUserList{}
	for row in result {
		user_roles := core_user_role.select()!.where('user_id = ?', row.id)!.query()!
		mut role_ids := []string{}
		for user_role in user_roles {
			role_ids << user_role.role_id
		}

		datalist << GetUserList{
			id:          row.id
			username:    row.username
			nickname:    row.nickname
			email:       row.email or { '' }
			role_ids:    role_ids
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
