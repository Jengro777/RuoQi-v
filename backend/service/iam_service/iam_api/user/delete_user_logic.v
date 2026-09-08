module user

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/delete_user'; post]
pub fn (app &User) delete_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteUserReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_user_usecase(mut ctx Context, req DeleteUserReq) !DeleteUserResp {
	delete_user_domain(req)!
	delete_user_repo(mut ctx, req) or { return error('Failed to delete user: ${err}') }
	return DeleteUserResp{
		msg: 'User deleted'
	}
}

// ═══ Domain ═══
fn delete_user_domain(req DeleteUserReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ═══ DTO ═══
pub struct DeleteUserReq {
	user_id string @[json: 'id']
}

pub struct DeleteUserResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_user_repo(mut ctx Context, req DeleteUserReq) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamUser set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id == req.user_id && del_flag == 0
	} or { return error('Failed to delete user: ${err}') }
}
