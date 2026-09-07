module emaillog

import veb
import log
import time
import rand
import json2 as json
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &EmailLog) create_email_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateEmailLogReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_email_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_email_log_usecase(mut ctx Context, req CreateEmailLogReq) !CreateEmailLogResp {
	create_email_log_domain(req)!
	return create_email_log_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_email_log_domain(req CreateEmailLogReq) ! {
	if req.target == '' {
		return error('target email address is required')
	}
	if req.subject == '' {
		return error('subject is required')
	}
	if req.provider == '' {
		return error('provider is required')
	}
}

// ═══ DTO ═══
pub struct CreateEmailLogReq {
	target      string @[json: 'target']
	subject     string @[json: 'subject']
	content     string @[json: 'content']
	send_status u8 @[json: 'sendStatus']
	provider    string @[json: 'provider']
}

pub struct CreateEmailLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_email_log_repo(mut ctx Context, req CreateEmailLogReq) !CreateEmailLogResp {
	time_now := time.now()
	email_log := MsgEmailLog{
		id: rand.uuid_v7()
		target: req.target
		subject: req.subject
		content: req.content
		send_status: req.send_status
		provider: req.provider
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert email_log into MsgEmailLog
	} or { return error('Failed to create EmailLog: ${err}') }

	return CreateEmailLogResp{
		msg: 'EmailLog created successfully'
	}
}
