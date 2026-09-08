module smslog

import time
import veb
import log
import json2 as json
import model.schema_msg { MsgSmsLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &SmsLog) delete_sms_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteSmsLogReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_sms_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_sms_log_usecase(mut ctx Context, req DeleteSmsLogReq) !DeleteSmsLogResp {
	delete_sms_log_domain(req)!
	return delete_sms_log_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_sms_log_domain(req DeleteSmsLogReq) ! {
	if req.ids.len == 0 {
		return error('No SmsLog ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteSmsLogReq {
	ids []string @[json: 'ids']
}

pub struct DeleteSmsLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_sms_log_repo(mut ctx Context, ids []string) !DeleteSmsLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update MsgSmsLog set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to soft-delete sms log: ${err}') }

	return DeleteSmsLogResp{
		msg: '${ids.len} SmsLog(s) deleted successfully'
	}
}
