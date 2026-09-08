module user

import veb
import log
import json2 as json
import model { Context }
import model.schema_iam { IamUser }
import common.api
import time

// ═══ Handler ═══
@['/update_user_profile'; post]
pub fn (app &User) update_user_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateUserProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_user_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_user_profile_usecase(mut ctx Context, req UpdateUserProfileReq) !UpdateUserProfileResp {
	update_user_profile_domain(mut ctx)!
	update_user_profile_repo(mut ctx, req)!
	return UpdateUserProfileResp{
		msg: 'Profile updated'
	}
}

// ═══ Domain ═══
fn update_user_profile_domain(mut ctx Context) ! {
	if ctx.svc_iam.user_id == '' {
		return error('user not authenticated')
	}
}

// ═══ DTO ═══
pub struct UpdateUserProfileReq {
	nickname    ?string @[json: 'nickname']
	email       ?string @[json: 'email']
	mobile      ?string @[json: 'mobile']
	description ?string @[json: 'description']
	avatar      ?string @[json: 'avatar']
}

pub struct UpdateUserProfileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_user_profile_repo(mut ctx Context, req UpdateUserProfileReq) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.nickname {
			nickname == v
		},
		if v := req.email {
			email == v
		},
		if v := req.mobile {
			mobile == v
		},
		if v := req.description {
			description == v
		},
		if v := req.avatar {
			avatar == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update IamUser set up_expr where id == ctx.svc_iam.user_id
	}!
}
