module pay_api

import veb
import log
import time
import json2 as json
import model.schema_pay { PayOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/order/update'; post]
pub fn (app &Pay) update_pay_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_order_usecase(mut ctx Context, req UpdatePayOrderReq) !UpdatePayOrderResp {
	update_pay_order_domain(req)!
	return update_pay_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_order_domain(req UpdatePayOrderReq) ! {
	if req.id == '' {
		return error('pay order id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayOrderReq {
	id                string @[json: 'id']
	channel_code      ?string @[json: 'channelCode']
	merchant_order_id ?string @[json: 'merchantOrderId']
	subject           ?string @[json: 'subject']
	body              ?string @[json: 'body']
	price             ?int @[json: 'price']
	channel_fee_rate  ?f64 @[json: 'channelFeeRate']
	channel_fee_price ?int @[json: 'channelFeePrice']
	user_ip           ?string @[json: 'userIp']
	refund_price      ?int @[json: 'refundPrice']
	channel_user_id   ?string @[json: 'channelUserId']
	channel_order_no  ?string @[json: 'channelOrderNo']
	success_time      ?time.Time @[json: 'successTime']
	notify_time       ?time.Time @[json: 'notifyTime']
	status            ?u8 @[json: 'status']
}

pub struct UpdatePayOrderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_pay_order_repo(mut ctx Context, req UpdatePayOrderReq) !UpdatePayOrderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.channel_code {
			channel_code == v
		},
		if v := req.merchant_order_id {
			merchant_order_id == v
		},
		if v := req.subject {
			subject == v
		},
		if v := req.body {
			body == v
		},
		if v := req.price {
			price == v
		},
		if v := req.channel_fee_rate {
			channel_fee_rate == v
		},
		if v := req.channel_fee_price {
			channel_fee_price == v
		},
		if v := req.user_ip {
			user_ip == v
		},
		if v := req.refund_price {
			refund_price == v
		},
		if v := req.channel_user_id {
			channel_user_id == v
		},
		if v := req.channel_order_no {
			channel_order_no == v
		},
		if v := req.success_time {
			success_time == v
		},
		if v := req.notify_time {
			notify_time == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update PayOrder set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdatePayOrderResp{
		msg: 'PayOrder updated successfully'
	}
}
