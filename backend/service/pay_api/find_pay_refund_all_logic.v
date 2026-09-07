module pay_api

import veb
import log
import time
import model.schema_pay { PayRefund }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/refund/all'; get]
pub fn (app &Pay) find_pay_refund_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayRefundListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_pay_refund_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_pay_refund_all_usecase(mut ctx Context, req PayRefundListReq) !PayRefundListResp {
	find_pay_refund_all_domain(req)!
	return find_pay_refund_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_refund_all_domain(req PayRefundListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayRefundListReq {
	page         int @[json: 'page']
	page_size    int @[json: 'pageSize']
	order_id     string @[json: 'orderId']
	channel_code string @[json: 'channelCode']
	status       []u8 @[json: 'status']
}

pub struct PayRefundData {
	id                 string @[json: 'id']
	no                 string @[json: 'no']
	channel_code       string @[json: 'channelCode']
	order_id           string @[json: 'orderId']
	order_no           string @[json: 'orderNo']
	merchant_order_id  string @[json: 'merchantOrderId']
	merchant_refund_id string @[json: 'merchantRefundId']
	pay_price          int @[json: 'payPrice']
	refund_price       int @[json: 'refundPrice']
	reason             string @[json: 'reason']
	channel_refund_no  ?string @[json: 'channelRefundNo']
	status             u8 @[json: 'status']
	updater_id         ?string @[json: 'updaterId']
	creator_id         ?string @[json: 'creatorId']
	created_at         string @[json: 'createdAt']
	updated_at         string @[json: 'updatedAt']
	deleted_at         string @[json: 'deletedAt']
}

pub struct PayRefundListResp {
	total int
	data  []PayRefundData
}

// ═══ Repository ═══
fn find_pay_refund_all_repo(mut ctx Context, req PayRefundListReq) !PayRefundListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayRefund where del_flag == 0
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
		dynamic select from PayRefund where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayRefundData{}
	for row in result {
		datalist << PayRefundData{
			id: row.id
			no: row.no
			channel_code: row.channel_code
			order_id: row.order_id
			order_no: row.order_no
			merchant_order_id: row.merchant_order_id
			merchant_refund_id: row.merchant_refund_id
			pay_price: row.pay_price
			refund_price: row.refund_price
			reason: row.reason
			channel_refund_no: row.channel_refund_no
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayRefundListResp{
		total: count
		data: datalist
	}
}
