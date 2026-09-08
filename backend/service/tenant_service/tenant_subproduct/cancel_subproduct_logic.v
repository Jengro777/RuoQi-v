module tenant_subproduct

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_tenant { TnSubProduct }
import common.api as capi

// ═══ Handler ═══
@['/cancel_subproduct'; post]
pub fn (app &TenantSubProduct) cancel_subproduct_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CancelSubProductReq](ctx.req.data) or {
		return ctx.json(capi.json_error(code: capi.err_common_param_invalid, msg: err.msg()))
	}
	result := cancel_subproduct_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn cancel_subproduct_usecase(mut ctx Context, req CancelSubProductReq) !CancelSubProductResp {
	cancel_subproduct_domain(req)!
	return cancel_subproduct_repo(mut ctx, req)
}

// ═══ Domain ═══
fn cancel_subproduct_domain(req CancelSubProductReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct CancelSubProductReq {
	id string @[json: 'id']
}

pub struct CancelSubProductResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn cancel_subproduct_repo(mut ctx Context, req CancelSubProductReq) !CancelSubProductResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update TnSubProduct set del_flag = -1, status = 2, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id == req.id && del_flag == 0
	} or { return error('Failed to cancel subproduct: ${err}') }
	return CancelSubProductResp{
		msg: '订阅已取消'
	}
}
