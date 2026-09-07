module pay_api

import veb
import log
import time
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/extension/all'; get]
pub fn (app &Pay) find_pay_order_extension_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayOrderExtensionListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_pay_order_extension_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_pay_order_extension_all_usecase(mut ctx Context, req PayOrderExtensionListReq) !PayOrderExtensionListResp {
	find_pay_order_extension_all_domain(req)!
	return find_pay_order_extension_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_order_extension_all_domain(req PayOrderExtensionListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayOrderExtensionListReq {
	page         int @[json: 'page']
	page_size    int @[json: 'pageSize']
	order_id     string @[json: 'orderId']
	channel_code string @[json: 'channelCode']
	status       []u8 @[json: 'status']
}

pub struct PayOrderExtensionData {
	id                  string @[json: 'id']
	no                  string @[json: 'no']
	order_id            string @[json: 'orderId']
	channel_code        string @[json: 'channelCode']
	user_ip             string @[json: 'userIp']
	channel_extras      ?string @[json: 'channelExtras']
	channel_error_code  ?string @[json: 'channelErrorCode']
	channel_error_msg   ?string @[json: 'channelErrorMsg']
	channel_notify_data ?string @[json: 'channelNotifyData']
	status              u8 @[json: 'status']
	updater_id          ?string @[json: 'updaterId']
	creator_id          ?string @[json: 'creatorId']
	created_at          string @[json: 'createdAt']
	updated_at          string @[json: 'updatedAt']
	deleted_at          string @[json: 'deletedAt']
}

pub struct PayOrderExtensionListResp {
	total int
	data  []PayOrderExtensionData
}

// ═══ Repository ═══
fn find_pay_order_extension_all_repo(mut ctx Context, req PayOrderExtensionListReq) !PayOrderExtensionListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayOrderExtension where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.order_id != '' {order_id == req.order_id},
		if req.channel_code != '' {channel_code == req.channel_code},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from PayOrderExtension where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayOrderExtensionData{}
	for row in result {
		datalist << PayOrderExtensionData{
			id: row.id
			no: row.no
			order_id: row.order_id
			channel_code: row.channel_code
			user_ip: row.user_ip
			channel_extras: row.channel_extras
			channel_error_code: row.channel_error_code
			channel_error_msg: row.channel_error_msg
			channel_notify_data: row.channel_notify_data
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayOrderExtensionListResp{
		total: count
		data: datalist
	}
}
