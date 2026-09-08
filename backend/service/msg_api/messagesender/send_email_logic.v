module messagesender

import veb
import log
import time
import rand
import json2 as json
import model.schema_msg { MsgEmailLog, MsgEmailProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/send_email'; post]
pub fn (app &MessageSender) send_email_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[SendEmailReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := send_email_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn send_email_usecase(mut ctx Context, req SendEmailReq) !SendEmailResp {
	send_email_domain(req)!
	return send_email_repo(mut ctx, req)
}

// ═══ Domain ═══
fn send_email_domain(req SendEmailReq) ! {
	if req.target == '' {
		return error('target email address is required')
	}
	if req.subject == '' {
		return error('subject is required')
	}
	if req.provider == '' {
		return error('provider name is required')
	}
}

// ═══ DTO ═══
pub struct SendEmailReq {
	target   string @[json: 'target']
	subject  string @[json: 'subject']
	content  string @[json: 'content']
	provider string @[json: 'provider']
}

pub struct SendEmailResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn send_email_repo(mut ctx Context, req SendEmailReq) !SendEmailResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// Look up the provider to verify it exists
	providers := sql db {
		select from MsgEmailProvider where name == req.provider limit 1
	} or { return error('Failed to lookup provider: ${err}') }

	if providers.len == 0 {
		return error('EmailProvider "${req.provider}" not found')
	}

	// Insert send log with pending status (0 = unknown/pending)
	time_now := time.now()
	email_log := MsgEmailLog{
		id: rand.uuid_v7()
		target: req.target
		subject: req.subject
		content: req.content
		send_status: 0
		provider: req.provider
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		insert email_log into MsgEmailLog
	} or { return error('Failed to create email send log: ${err}') }

	return SendEmailResp{
		msg: 'Email queued successfully to ${req.target}'
	}
}
