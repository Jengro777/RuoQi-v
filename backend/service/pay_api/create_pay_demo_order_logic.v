module pay_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayDemoOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/demo/create'; post]
pub fn (app &Pay) create_pay_demo_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayDemoOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_pay_demo_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_pay_demo_order_usecase(mut ctx Context, req CreatePayDemoOrderReq) !CreatePayDemoOrderResp {
	create_pay_demo_order_domain(req)!
	return create_pay_demo_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_demo_order_domain(req CreatePayDemoOrderReq) ! {
	if req.price <= 0 {
		return error('price must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct CreatePayDemoOrderReq {
	user_id    string @[json: 'userId']
	spu_id     u64 @[json: 'spuId']
	spu_name   string @[json: 'spuName']
	price      int @[json: 'price']
	pay_status u8 @[json: 'payStatus']
}

pub struct CreatePayDemoOrderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_pay_demo_order_repo(mut ctx Context, req CreatePayDemoOrderReq) !CreatePayDemoOrderResp {
	time_now := time.now()
	order := PayDemoOrder{
		id: rand.uuid_v7()
		user_id: ctx.svc_iam.user_id
		spu_id: req.spu_id
		spu_name: req.spu_name
		price: req.price
		pay_status: req.pay_status
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
		insert order into PayDemoOrder
	} or { return error('Failed to create PayDemoOrder: ${err}') }

	return CreatePayDemoOrderResp{
		msg: 'PayDemoOrder created successfully'
	}
}
