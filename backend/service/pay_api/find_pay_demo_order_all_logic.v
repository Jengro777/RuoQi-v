module pay_api

import veb
import log
import time
import model.schema_pay { PayDemoOrder }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/demo/all'; get]
pub fn (app &Pay) find_pay_demo_order_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayDemoOrderListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_pay_demo_order_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_pay_demo_order_all_usecase(mut ctx Context, req PayDemoOrderListReq) !PayDemoOrderListResp {
	find_pay_demo_order_all_domain(req)!
	return find_pay_demo_order_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_demo_order_all_domain(req PayDemoOrderListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayDemoOrderListReq {
	page       int @[json: 'page']
	page_size  int @[json: 'pageSize']
	user_id    string @[json: 'userId']
	spu_name   string @[json: 'spuName']
	pay_status []u8 @[json: 'payStatus']
}

pub struct PayDemoOrderData {
	id               string @[json: 'id']
	user_id          string @[json: 'userId']
	spu_id           u64 @[json: 'spuId']
	spu_name         string @[json: 'spuName']
	price            int @[json: 'price']
	pay_status       u8 @[json: 'payStatus']
	pay_order_id     ?string @[json: 'payOrderId']
	pay_channel_code ?string @[json: 'payChannelCode']
	pay_refund_id    ?string @[json: 'payRefundId']
	refund_price     ?int @[json: 'refundPrice']
	updater_id       ?string @[json: 'updaterId']
	creator_id       ?string @[json: 'creatorId']
	created_at       string @[json: 'createdAt']
	updated_at       string @[json: 'updatedAt']
	deleted_at       string @[json: 'deletedAt']
}

pub struct PayDemoOrderListResp {
	total int
	data  []PayDemoOrderData
}

// ═══ Repository ═══
fn find_pay_demo_order_all_repo(mut ctx Context, req PayDemoOrderListReq) !PayDemoOrderListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayDemoOrder where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.user_id != '' {user_id == req.user_id},
		if req.spu_name != '' {spu_name == req.spu_name},
		if req.pay_status.len > 0 {pay_status in req.pay_status}
	}
	// vfmt on
	result := sql db {
		dynamic select from PayDemoOrder where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayDemoOrderData{}
	for row in result {
		datalist << PayDemoOrderData{
			id: row.id
			user_id: row.user_id
			spu_id: row.spu_id
			spu_name: row.spu_name
			price: row.price
			pay_status: row.pay_status
			pay_order_id: row.pay_order_id
			pay_channel_code: row.pay_channel_code
			pay_refund_id: row.pay_refund_id
			refund_price: row.refund_price
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayDemoOrderListResp{
		total: count
		data: datalist
	}
}
