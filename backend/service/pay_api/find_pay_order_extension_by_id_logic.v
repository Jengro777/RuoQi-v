module pay_api

import veb
import log
import json2 as json
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }

// ═══ Handler ═══
@['/extension/by_id'; post]
pub fn (app &Pay) find_pay_order_extension_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayOrderExtensionByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_pay_order_extension_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_pay_order_extension_by_id_usecase(mut ctx Context, req PayOrderExtensionByIdReq) !PayOrderExtension {
	find_pay_order_extension_by_id_domain(req)!
	return find_pay_order_extension_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_order_extension_by_id_domain(req PayOrderExtensionByIdReq) ! {
	if req.id == '' {
		return error('order extension id is required')
	}
}

// ═══ DTO ═══
pub struct PayOrderExtensionByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_pay_order_extension_by_id_repo(mut ctx Context, req PayOrderExtensionByIdReq) !PayOrderExtension {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	extensions := sql db {
		select from PayOrderExtension where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if extensions.len == 0 {
		return error('PayOrderExtension not found')
	}

	return extensions[0]
}
