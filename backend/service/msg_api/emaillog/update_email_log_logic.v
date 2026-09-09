module emaillog

import veb
import log
import time
import json2 as json
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &EmailLog) update_email_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateEmailLogReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_email_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_email_log_usecase(mut ctx Context, req UpdateEmailLogReq) !UpdateEmailLogResp {
	update_email_log_domain(req)!
	return update_email_log_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_email_log_domain(req UpdateEmailLogReq) ! {
	if req.id == '' {
		return error('email log id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateEmailLogReq {
	id          string @[json: 'id']
	target      ?string @[json: 'target']
	subject     ?string @[json: 'subject']
	content     ?string @[json: 'content']
	send_status ?u8 @[json: 'sendStatus']
	provider    ?string @[json: 'provider']
}

pub struct UpdateEmailLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_email_log_repo(mut ctx Context, req UpdateEmailLogReq) !UpdateEmailLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.target {
			target == v
		},
		if v := req.subject {
			subject == v
		},
		if v := req.content {
			content == v
		},
		if v := req.send_status {
			send_status == v
		},
		if v := req.provider {
			provider == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update MsgEmailLog set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateEmailLogResp{
		msg: 'EmailLog updated successfully'
	}
}
