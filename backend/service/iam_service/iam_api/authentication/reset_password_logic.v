module authentication

import veb
import log
import json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api
import common.encrypt

// ═══ Handler ═══
@['/reset_password'; post]
pub fn (app &Authentication) reset_password_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[ResetPasswordReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := reset_password_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn reset_password_usecase(mut ctx Context, req ResetPasswordReq) !ResetPasswordResp {
	reset_password_domain(req)!
	return reset_password_repo(mut ctx, req)
}

// ═══ Domain ═══
fn reset_password_domain(req ResetPasswordReq) ! {
	if req.user_id == '' { return error('user_id is required') }
	if req.old_password == '' { return error('old_password is required') }
	if req.new_password == '' { return error('new_password is required') }
}

// ═══ DTO ═══
pub struct ResetPasswordReq {
	user_id      string @[json: 'user_id']
	old_password string @[json: 'old_password']
	new_password string @[json: 'new_password']
}

pub struct ResetPasswordResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn reset_password_repo(mut ctx Context, req ResetPasswordReq) !ResetPasswordResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	user := sql db {
		select from IamUser where id == req.user_id limit 1
	} or { return error('Failed: ${err}') }
	if user.len == 0 { return error('user not found') }
	if !encrypt.bcrypt_verify(req.old_password, user[0].password) {
		return error('old password is incorrect')
	}
	new_hash := encrypt.bcrypt_hash(req.new_password) or { return error('Failed to hash password') }
	sql db {
		update IamUser set password = new_hash where id == req.user_id
	} or { return error('Failed to update password: ${err}') }
	return ResetPasswordResp{
		msg: 'Password updated'
	}
}
