module user

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api

@['/find_user_all'; post]
pub fn (app &User) find_user_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_user_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

@['/find_user_by_id'; post]
pub fn (app &User) find_user_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_user_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/find_user_info'; post]
pub fn (app &User) find_user_info_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_user_info_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

pub fn find_user_all_usecase(mut ctx Context) ![]IamUser {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	users := sql db {
		select from IamUser
	} or { return error('Failed: ${err}') }
	return users
}

pub fn find_user_by_id_usecase(mut ctx Context, req FindByIdReq) !IamUser {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	users := sql db {
		select from IamUser where id == req.id limit 1
	} or { return error('Failed: ${err}') }
	if users.len == 0 { return error('user not found') }
	return users[0]
}

pub fn find_user_info_usecase(mut ctx Context) !IamUser {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	users := sql db {
		select from IamUser where id == ctx.svc_iam.user_id limit 1
	} or { return error('Failed: ${err}') }
	if users.len == 0 { return error('user not found') }
	return users[0]
}

pub struct FindByIdReq {
	id string @[json: 'id']
}
