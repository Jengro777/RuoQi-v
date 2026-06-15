module user

import veb
import log
import structs { Context }
import structs.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/profile'; get]
pub fn (app &User) find_user_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_user_profile_usecase(mut ctx) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_user_profile_usecase(mut ctx Context) !UserProfileResp {
	find_user_profile_domain(mut ctx)!
	return find_user_profile_repo(mut ctx)
}

// ═══ Domain ═══
fn find_user_profile_domain(mut ctx Context) ! {
	if ctx.svc_iam.user_id == '' {
		return error('user not authenticated')
	}
}

// ═══ DTO ═══
pub struct UserProfileResp {
	user_id     string @[json: 'user_id']
	username    string @[json: 'username']
	nickname    string @[json: 'nickname']
	avatar      string @[json: 'avatar']
	email       string @[json: 'email']
	mobile      string @[json: 'mobile']
	description string @[json: 'description']
	home_path   string @[json: 'homePath']
}

// ═══ Repository ═══
fn find_user_profile_repo(mut ctx Context) !UserProfileResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	user := sql db {
		select from IamUser where id == ctx.svc_iam.user_id limit 1
	} or { return error('Failed: ${err}') }
	if user.len == 0 { return error('user not found') }
	return UserProfileResp{
		user_id:     user[0].id
		username:    user[0].username
		nickname:    user[0].nickname
		avatar:      user[0].avatar
		email:       user[0].email
		mobile:      user[0].mobile
		description: user[0].description
		home_path:   user[0].home_path
	}
}
