module emaillog

import time
import veb
import log
import json2 as json
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &EmailLog) delete_email_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteEmailLogReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_email_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_email_log_usecase(mut ctx Context, req DeleteEmailLogReq) !DeleteEmailLogResp {
	delete_email_log_domain(req)!
	return delete_email_log_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_email_log_domain(req DeleteEmailLogReq) ! {
	if req.ids.len == 0 {
		return error('No EmailLog ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteEmailLogReq {
	ids []string @[json: 'ids']
}

pub struct DeleteEmailLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_email_log_repo(mut ctx Context, ids []string) !DeleteEmailLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update MsgEmailLog set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to soft-delete email log: ${err}') }

	return DeleteEmailLogResp{
		msg: '${ids.len} EmailLog(s) deleted successfully'
	}
}
