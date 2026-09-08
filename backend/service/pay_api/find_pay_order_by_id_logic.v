module pay_api

import veb
import log
import json2 as json
import model.schema_pay { PayOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/order/by_id'; post]
pub fn (app &Pay) find_pay_order_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayOrderByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_pay_order_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_pay_order_by_id_usecase(mut ctx Context, req PayOrderByIdReq) !PayOrder {
	find_pay_order_by_id_domain(req)!
	return find_pay_order_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_order_by_id_domain(req PayOrderByIdReq) ! {
	if req.id == '' {
		return error('pay order id is required')
	}
}

// ═══ DTO ═══
pub struct PayOrderByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_pay_order_by_id_repo(mut ctx Context, req PayOrderByIdReq) !PayOrder {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	orders := sql db {
		select from PayOrder where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if orders.len == 0 {
		return error('PayOrder not found')
	}

	return orders[0]
}
