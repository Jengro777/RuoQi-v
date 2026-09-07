module smslog

import veb
import log
import time
import model.schema_msg { MsgSmsLog }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &SmsLog) find_sms_log_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[SmsLogListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_sms_log_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_sms_log_all_usecase(mut ctx Context, req SmsLogListReq) !SmsLogListResp {
	find_sms_log_all_domain()
	return find_sms_log_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_sms_log_all_domain() {
}

// ═══ DTO ═══
pub struct SmsLogListReq {
	page         int @[json: 'page']
	page_size    int @[json: 'pageSize']
	phone_number string @[json: 'phoneNumber']
	provider     string @[json: 'provider']
	send_status  []u8 @[json: 'sendStatus']
}

pub struct SmsLogData {
	id           string @[json: 'id']
	phone_number string @[json: 'phoneNumber']
	content      string @[json: 'content']
	send_status  u8 @[json: 'sendStatus']
	provider     string @[json: 'provider']
	updater_id   ?string @[json: 'updaterId']
	creator_id   ?string @[json: 'creatorId']
	created_at   string @[json: 'createdAt']
	updated_at   string @[json: 'updatedAt']
	deleted_at   string @[json: 'deletedAt']
}

pub struct SmsLogListResp {
	total int
	data  []SmsLogData
}

// ═══ Repository ═══
fn find_sms_log_all_repo(mut ctx Context, req SmsLogListReq) !SmsLogListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from MsgSmsLog
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		if req.phone_number != '' {phone_number == req.phone_number},
		if req.provider != '' {provider == req.provider},
		if req.send_status.len > 0 {send_status in req.send_status}
	}
	// vfmt on
	result := sql db {
		dynamic select from MsgSmsLog where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []SmsLogData{}
	for row in result {
		datalist << SmsLogData{
			id: row.id
			phone_number: row.phone_number
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

	return SmsLogListResp{
		total: count
		data: datalist
	}
}
