module pay_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/order/create'; post]
pub fn (app &Pay) create_pay_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_pay_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_pay_order_usecase(mut ctx Context, req CreatePayOrderReq) !CreatePayOrderResp {
	create_pay_order_domain(req)!
	return create_pay_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_order_domain(req CreatePayOrderReq) ! {
	if req.merchant_order_id == '' {
		return error('merchant order id is required')
	}
	if req.price <= 0 {
		return error('price must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct CreatePayOrderReq {
	channel_code      ?string @[json: 'channelCode']
	merchant_order_id string @[json: 'merchantOrderId']
	subject           string @[json: 'subject']
	body              string @[json: 'body']
	price             int @[json: 'price']
	channel_fee_rate  ?f64 @[json: 'channelFeeRate']
	channel_fee_price ?int @[json: 'channelFeePrice']
	user_ip           string @[json: 'userIp']
	expire_time       time.Time @[json: 'expireTime']
	status            u8 @[json: 'status']
}

pub struct CreatePayOrderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_pay_order_repo(mut ctx Context, req CreatePayOrderReq) !CreatePayOrderResp {
	time_now := time.now()
	order := PayOrder{
		id: rand.uuid_v7()
		channel_code: req.channel_code
		merchant_order_id: req.merchant_order_id
		subject: req.subject
		body: req.body
		price: req.price
		channel_fee_rate: req.channel_fee_rate
		channel_fee_price: req.channel_fee_price
		user_ip: req.user_ip
		expire_time: req.expire_time
		refund_price: 0
		status: req.status
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
		insert order into PayOrder
	} or { return error('Failed to create PayOrder: ${err}') }

	return CreatePayOrderResp{
		msg: 'PayOrder created successfully'
	}
}
