module pay_api

import time
import veb
import log
import json2 as json
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }

// ═══ Handler ═══
@['/extension/delete'; post]
pub fn (app &Pay) delete_pay_order_extension_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeletePayOrderExtensionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_pay_order_extension_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_pay_order_extension_usecase(mut ctx Context, req DeletePayOrderExtensionReq) !DeletePayOrderExtensionResp {
	delete_pay_order_extension_domain(req)!
	return delete_pay_order_extension_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_pay_order_extension_domain(req DeletePayOrderExtensionReq) ! {
	if req.ids.len == 0 {
		return error('No PayOrderExtension ids provided')
	}
}

// ═══ DTO ═══
pub struct DeletePayOrderExtensionReq {
	ids []string @[json: 'ids']
}

pub struct DeletePayOrderExtensionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_pay_order_extension_repo(mut ctx Context, ids []string) !DeletePayOrderExtensionResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update PayOrderExtension set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to soft-delete order extension: ${err}') }

	return DeletePayOrderExtensionResp{
		msg: '${ids.len} PayOrderExtension(s) deleted successfully'
	}
}
