module user

import veb
import log
import json2 as json
import model { Context }
import model.schema_iam { IamUser }
import common.api
import common.encrypt

// ═══ Handler ═══
@['/update_user'; post]
pub fn (app &User) update_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_user_usecase(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	update_user_domain(req)!
	password_hash := if pwd := req.password {
		encrypt.bcrypt_hash(pwd) or { return error('Failed to hash password') }
	} else {
		''
	}
	update_user_repo(mut ctx, req, password_hash)!
	return UpdateUserResp{
		msg: 'User updated'
	}
}

// ═══ Domain ═══
fn update_user_domain(req UpdateUserReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateUserReq {
	user_id     string @[json: 'id']
	avatar      ?string @[json: 'avatar']
	description ?string @[json: 'description']
	email       ?string @[json: 'email']
	home_path   ?string @[json: 'homePath']
	mobile      ?string @[json: 'mobile']
	nickname    ?string @[json: 'nickname']
	password    ?string @[json: 'password']
	status      ?u8 @[json: 'status']
	username    ?string @[json: 'username']
}

pub struct UpdateUserResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_user_repo(mut ctx Context, req UpdateUserReq, password_hash string) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr :=
		sql {
		}
	sql db {
		dynamic update IamUser set up_expr where id == req.user_id
	}!
}
