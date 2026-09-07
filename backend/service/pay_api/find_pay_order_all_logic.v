module pay_api

import veb
import log
import time
import model.schema_pay { PayOrder }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/order/all'; get]
pub fn (app &Pay) find_pay_order_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayOrderListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_pay_order_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_pay_order_all_usecase(mut ctx Context, req PayOrderListReq) !PayOrderListResp {
	find_pay_order_all_domain(req)!
	return find_pay_order_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_order_all_domain(req PayOrderListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayOrderListReq {
	page              int @[json: 'page']
	page_size         int @[json: 'pageSize']
	merchant_order_id string @[json: 'merchantOrderId']
	channel_code      string @[json: 'channelCode']
	status            []u8 @[json: 'status']
}

pub struct PayOrderData {
	id                string @[json: 'id']
	channel_code      ?string @[json: 'channelCode']
	merchant_order_id string @[json: 'merchantOrderId']
	subject           string @[json: 'subject']
	body              string @[json: 'body']
	price             int @[json: 'price']
	channel_fee_rate  ?f64 @[json: 'channelFeeRate']
	channel_fee_price ?int @[json: 'channelFeePrice']
	user_ip           string @[json: 'userIp']
	refund_price      int @[json: 'refundPrice']
	channel_order_no  ?string @[json: 'channelOrderNo']
	status            u8 @[json: 'status']
	updater_id        ?string @[json: 'updaterId']
	creator_id        ?string @[json: 'creatorId']
	created_at        string @[json: 'createdAt']
	updated_at        string @[json: 'updatedAt']
	deleted_at        string @[json: 'deletedAt']
}

pub struct PayOrderListResp {
	total int
	data  []PayOrderData
}

// ═══ Repository ═══
fn find_pay_order_all_repo(mut ctx Context, req PayOrderListReq) !PayOrderListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayOrder where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.merchant_order_id != '' {merchant_order_id == req.merchant_order_id},
		if req.channel_code != '' {channel_code == req.channel_code},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from PayOrder where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayOrderData{}
	for row in result {
		datalist << PayOrderData{
			id: row.id
			channel_code: row.channel_code
			merchant_order_id: row.merchant_order_id
			subject: row.subject
			body: row.body
			price: row.price
			channel_fee_rate: row.channel_fee_rate
			channel_fee_price: row.channel_fee_price
			user_ip: row.user_ip
			refund_price: row.refund_price
			channel_order_no: row.channel_order_no
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayOrderListResp{
		total: count
		data: datalist
	}
}
