module profile

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/update_profile'; post]
pub fn (app &Profile) update_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_profile_usecase(mut ctx Context, req UpdateProfileReq) !UpdateProfileResp {
	update_profile_domain(mut ctx)!
	update_profile_repo(mut ctx, req)!
	return UpdateProfileResp{
		msg: 'Profile updated successfully'
	}
}

// ═══ Domain ═══
fn update_profile_domain(mut ctx Context) ! {
	if ctx.svc_iam.user_id == '' {
		return error('user not authenticated')
	}
}

// ═══ DTO ═══
pub struct UpdateProfileReq {
	nickname    string @[json: 'nickname']
	email       string @[json: 'email']
	mobile      string @[json: 'mobile']
	avatar      string @[json: 'avatar']
	description string @[json: 'description']
}

pub struct UpdateProfileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_profile_repo(mut ctx Context, req UpdateProfileReq) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamUser set nickname = req.nickname, email = req.email, mobile = req.mobile,
		avatar = req.avatar, description = req.description, updated_at = time.now() where id == ctx.svc_iam.user_id
	}!
}
