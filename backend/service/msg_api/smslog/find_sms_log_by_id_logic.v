module smslog

import veb
import log
import json2 as json
import model.schema_msg { MsgSmsLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/find_sms_log_by_id'; post]
pub fn (app &SmsLog) find_sms_log_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[SmsLogByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_sms_log_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_sms_log_by_id_usecase(mut ctx Context, req SmsLogByIdReq) !MsgSmsLog {
	find_sms_log_by_id_domain(req)!
	return find_sms_log_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_sms_log_by_id_domain(req SmsLogByIdReq) ! {
	if req.id == '' {
		return error('sms log id is required')
	}
}

// ═══ DTO ═══
pub struct SmsLogByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_sms_log_by_id_repo(mut ctx Context, req SmsLogByIdReq) !MsgSmsLog {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sms_logs := sql db {
		select from MsgSmsLog where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if sms_logs.len == 0 {
		return error('SmsLog not found')
	}

	return sms_logs[0]
}
