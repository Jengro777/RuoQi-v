module pay_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }

// ═══ Handler ═══
@['/extension/create'; post]
pub fn (app &Pay) create_pay_order_extension_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayOrderExtensionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_pay_order_extension_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_pay_order_extension_usecase(mut ctx Context, req CreatePayOrderExtensionReq) !CreatePayOrderExtensionResp {
	create_pay_order_extension_domain(req)!
	return create_pay_order_extension_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_order_extension_domain(req CreatePayOrderExtensionReq) ! {
	if req.order_id == '' {
		return error('order id is required')
	}
}

// ═══ DTO ═══
pub struct CreatePayOrderExtensionReq {
	no             string @[json: 'no']
	order_id       string @[json: 'orderId']
	channel_code   string @[json: 'channelCode']
	user_ip        string @[json: 'userIp']
	channel_extras ?string @[json: 'channelExtras']
	status         u8 @[json: 'status']
}

pub struct CreatePayOrderExtensionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_pay_order_extension_repo(mut ctx Context, req CreatePayOrderExtensionReq) !CreatePayOrderExtensionResp {
	time_now := time.now()
	ext := PayOrderExtension{
		id: rand.uuid_v7()
		no: req.no
		order_id: req.order_id
		channel_code: req.channel_code
		user_ip: req.user_ip
		channel_extras: req.channel_extras
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
		insert ext into PayOrderExtension
	} or { return error('Failed to create PayOrderExtension: ${err}') }

	return CreatePayOrderExtensionResp{
		msg: 'PayOrderExtension created successfully'
	}
}
