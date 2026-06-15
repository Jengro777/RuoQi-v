module user

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/update_user_profile'; post]
pub fn (app &User) update_user_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateUserProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_user_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
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
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if nickname := req.nickname { nickname == nickname },
		if email := req.email { email == email },
		if mobile := req.mobile { mobile == mobile },
		if description := req.description { description == description },
		if avatar := req.avatar { avatar == avatar }
	}
	sql db {
		dynamic update IamUser set up_expr where id == ctx.svc_iam.user_id
	}!
}
