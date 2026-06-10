module profile

import veb
import log
import time
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamUser }
import common.api

@['/update_profile'; post]
pub fn (app &Profile) update_profile_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateProfileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_profile_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn update_profile_usecase(mut ctx Context, req UpdateProfileReq) !UpdateProfileResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	sql db {
		update IamUser set nickname = req.nickname, email = req.email, mobile = req.mobile,
		avatar = req.avatar, description = req.description, updated_at = time.now() where id == ctx.svc_iam.user_id
	}!
	return UpdateProfileResp{
		msg: 'Profile updated successfully'
	}
}

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
