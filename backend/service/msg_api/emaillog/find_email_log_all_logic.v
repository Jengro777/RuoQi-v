module emaillog

import veb
import log
import time
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &EmailLog) find_email_log_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailLogListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_email_log_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_email_log_all_usecase(mut ctx Context, req EmailLogListReq) !EmailLogListResp {
	find_email_log_all_domain()
	return find_email_log_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_email_log_all_domain() {
}

// ═══ DTO ═══
pub struct EmailLogListReq {
	page        int @[json: 'page']
	page_size   int @[json: 'pageSize']
	target      string @[json: 'target']
	subject     string @[json: 'subject']
	provider    string @[json: 'provider']
	send_status []u8 @[json: 'sendStatus']
}

pub struct EmailLogData {
	id          string @[json: 'id']
	target      string @[json: 'target']
	subject     string @[json: 'subject']
	content     string @[json: 'content']
	send_status u8 @[json: 'sendStatus']
	provider    string @[json: 'provider']
	updater_id  ?string @[json: 'updaterId']
	creator_id  ?string @[json: 'creatorId']
	created_at  string @[json: 'createdAt']
	updated_at  string @[json: 'updatedAt']
	deleted_at  string @[json: 'deletedAt']
}

pub struct EmailLogListResp {
	total int
	data  []EmailLogData
}

// ═══ Repository ═══
fn find_email_log_all_repo(mut ctx Context, req EmailLogListReq) !EmailLogListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from MsgEmailLog
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		if req.target != '' {target == req.target},
		if req.subject != '' {subject == req.subject},
		if req.provider != '' {provider == req.provider},
		if req.send_status.len > 0 {send_status in req.send_status}
	}
	// vfmt on
	result := sql db {
		dynamic select from MsgEmailLog where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []EmailLogData{}
	for row in result {
		datalist << EmailLogData{
			id: row.id
			target: row.target
			subject: row.subject
			content: row.content
			send_status: row.send_status
			provider: row.provider
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return EmailLogListResp{
		total: count
		data: datalist
	}
}
