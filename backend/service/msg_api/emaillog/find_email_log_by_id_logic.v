module emaillog

import veb
import log
import json2 as json
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/find_email_log_by_id'; post]
pub fn (app &EmailLog) find_email_log_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailLogByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_email_log_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_email_log_by_id_usecase(mut ctx Context, req EmailLogByIdReq) !MsgEmailLog {
	find_email_log_by_id_domain(req)!
	return find_email_log_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_email_log_by_id_domain(req EmailLogByIdReq) ! {
	if req.id == '' {
		return error('email log id is required')
	}
}

// ═══ DTO ═══
pub struct EmailLogByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_email_log_by_id_repo(mut ctx Context, req EmailLogByIdReq) !MsgEmailLog {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	email_logs := sql db {
		select from MsgEmailLog where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if email_logs.len == 0 {
		return error('EmailLog not found')
	}

	return email_logs[0]
}
