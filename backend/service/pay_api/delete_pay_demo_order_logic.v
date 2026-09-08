module pay_api

import time
import veb
import log
import json2 as json
import model.schema_pay { PayDemoOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/demo/delete'; post]
pub fn (app &Pay) delete_pay_demo_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeletePayDemoOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_pay_demo_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_pay_demo_order_usecase(mut ctx Context, req DeletePayDemoOrderReq) !DeletePayDemoOrderResp {
	delete_pay_demo_order_domain(req)!
	return delete_pay_demo_order_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_pay_demo_order_domain(req DeletePayDemoOrderReq) ! {
	if req.ids.len == 0 {
		return error('No PayDemoOrder ids provided')
	}
}

// ═══ DTO ═══
pub struct DeletePayDemoOrderReq {
	ids []string @[json: 'ids']
}

pub struct DeletePayDemoOrderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_pay_demo_order_repo(mut ctx Context, ids []string) !DeletePayDemoOrderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update PayDemoOrder set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to soft-delete demo order: ${err}') }

	return DeletePayDemoOrderResp{
		msg: '${ids.len} PayDemoOrder(s) deleted successfully'
	}
}
