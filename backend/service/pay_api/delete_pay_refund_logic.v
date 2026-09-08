module pay_api

import time
import veb
import log
import json2 as json
import model.schema_pay { PayRefund }
import common.api
import model { Context }

// ═══ Handler ═══
@['/refund/delete'; post]
pub fn (app &Pay) delete_pay_refund_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeletePayRefundReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_pay_refund_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_pay_refund_usecase(mut ctx Context, req DeletePayRefundReq) !DeletePayRefundResp {
	delete_pay_refund_domain(req)!
	return delete_pay_refund_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_pay_refund_domain(req DeletePayRefundReq) ! {
	if req.ids.len == 0 {
		return error('No PayRefund ids provided')
	}
}

// ═══ DTO ═══
pub struct DeletePayRefundReq {
	ids []string @[json: 'ids']
}

pub struct DeletePayRefundResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_pay_refund_repo(mut ctx Context, ids []string) !DeletePayRefundResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update PayRefund set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to soft-delete pay refund: ${err}') }

	return DeletePayRefundResp{
		msg: '${ids.len} PayRefund(s) deleted successfully'
	}
}
