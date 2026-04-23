module user

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreRole, CoreRoleTenantMember, CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/user/id'; post]
pub fn (app &User) user_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UserByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := user_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn user_by_id_usecase(mut ctx Context, req UserByIdReq) !UserByIdResp {
	// Domain 校验
	user_by_id_domain(req)!

	// Repository 查询
	return user_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn user_by_id_domain(req UserByIdReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UserByIdReq {
	user_id string @[json: 'user_id']
}

pub struct UserByIdResp {
	datalist []UserById @[json: 'datalist']
}

pub struct UserById {
	id         string     @[json: 'id']
	username   string     @[json: 'username']
	nickname   string     @[json: 'nickname']
	status     u8         @[json: 'status']
	role_ids   []string   @[json: 'role_ids']
	role_names []string   @[json: 'role_names']
	avatar     string     @[json: 'avatar']
	desc       string     @[json: 'desc']
	home_path  string     @[json: 'home_path']
	mobile     string     @[json: 'mobile']
	email      string     @[json: 'email']
	creator_id string     @[json: 'creator_id']
	updater_id string     @[json: 'updater_id']
	created_at time.Time  @[json: 'created_at']
	updated_at time.Time  @[json: 'updated_at']
	deleted_at ?time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn user_by_id_repo(mut ctx Context, req UserByIdReq) !UserByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	result := sql db {
		select from CoreUser where id == req.user_id
	} or { return error('Failed to execute SQL query: ${err}') }

	if result.len == 0 {
		return error('User not found')
	}

	user_data := result[0]

	// 查询用户角色关联
	mut user_roles := sql db {
		select from CoreRoleTenantMember where member_id == req.user_id
	}!

	mut role_ids := []string{}
	mut role_names := []string{}

	for row in user_roles {
		role_ids << row.role_id

		// 查询角色名称
		mut role := sql db {
			select from CoreRole where id == row.role_id
		}!
		for r in role {
			role_names << r.name
		}
	}

	data := UserById{
		id:         user_data.id
		username:   user_data.username
		nickname:   user_data.nickname
		status:     user_data.status
		role_ids:   role_ids
		role_names: role_names
		avatar:     user_data.avatar or { '' }
		desc:       user_data.description or { '' }
		home_path:  user_data.home_path
		email:      user_data.email or { '' }
		creator_id: user_data.creator_id or { '' }
		updater_id: user_data.updater_id or { '' }
		created_at: user_data.created_at
		updated_at: user_data.updated_at
		deleted_at: user_data.deleted_at
	}

	return UserByIdResp{
		datalist: [data]
	}
}
