module pay_api

import veb
import log
import time
import json2 as json
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }

// ═══ Handler ═══
@['/extension/update'; post]
pub fn (app &Pay) update_pay_order_extension_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayOrderExtensionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_order_extension_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_order_extension_usecase(mut ctx Context, req UpdatePayOrderExtensionReq) !UpdatePayOrderExtensionResp {
	update_pay_order_extension_domain(req)!
	return update_pay_order_extension_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_order_extension_domain(req UpdatePayOrderExtensionReq) ! {
	if req.id == '' {
		return error('order extension id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayOrderExtensionReq {
	id                  string @[json: 'id']
	channel_code        ?string @[json: 'channelCode']
	channel_extras      ?string @[json: 'channelExtras']
	channel_error_code  ?string @[json: 'channelErrorCode']
	channel_error_msg   ?string @[json: 'channelErrorMsg']
	channel_notify_data ?string @[json: 'channelNotifyData']
	status              ?u8 @[json: 'status']
}

pub struct UpdatePayOrderExtensionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_pay_order_extension_repo(mut ctx Context, req UpdatePayOrderExtensionReq) !UpdatePayOrderExtensionResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr :=
		sql {
		}

	sql db {
		dynamic update PayOrderExtension set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdatePayOrderExtensionResp{
		msg: 'PayOrderExtension updated successfully'
	}
}
