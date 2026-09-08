module messagesender

import veb
import log
import time
import rand
import json2 as json
import model.schema_msg { MsgSmsLog, MsgSmsProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/send_sms'; post]
pub fn (app &MessageSender) send_sms_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[SendSmsReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := send_sms_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn send_sms_usecase(mut ctx Context, req SendSmsReq) !SendSmsResp {
	send_sms_domain(req)!
	return send_sms_repo(mut ctx, req)
}

// ═══ Domain ═══
fn send_sms_domain(req SendSmsReq) ! {
	if req.phone_number == '' {
		return error('phone number is required')
	}
	if req.content == '' {
		return error('content is required')
	}
	if req.provider == '' {
		return error('provider name is required')
	}
}

// ═══ DTO ═══
pub struct SendSmsReq {
	phone_number string @[json: 'phoneNumber']
	content      string @[json: 'content']
	provider     string @[json: 'provider']
}

pub struct SendSmsResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn send_sms_repo(mut ctx Context, req SendSmsReq) !SendSmsResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// Look up the provider to verify it exists
	providers := sql db {
		select from MsgSmsProvider where name == req.provider limit 1
	} or { return error('Failed to lookup provider: ${err}') }

	if providers.len == 0 {
		return error('SmsProvider "${req.provider}" not found')
	}

	// Insert send log with pending status (0 = unknown/pending)
	time_now := time.now()
	sms_log := MsgSmsLog{
		id: rand.uuid_v7()
		phone_number: req.phone_number
		content: req.content
		send_status: 0
		provider: req.provider
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		insert sms_log into MsgSmsLog
	} or { return error('Failed to create sms send log: ${err}') }

	return SendSmsResp{
		msg: 'SMS queued successfully to ${req.phone_number}'
	}
}
