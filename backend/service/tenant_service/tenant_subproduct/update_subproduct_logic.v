module tenant_subproduct

import veb
import log
import json2 as json
import model { Context }
import model.schema_tenant { TnSubProduct }
import common.api as capi
import time

// ═══ Handler ═══
@['/update_subproduct'; post]
pub fn (app &TenantSubProduct) update_subproduct_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateSubProductReq](ctx.req.data) or {
		return ctx.json(capi.json_error(code: capi.err_common_param_invalid, msg: err.msg()))
	}
	result := update_subproduct_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_subproduct_usecase(mut ctx Context, req UpdateSubProductReq) !UpdateSubProductResp {
	update_subproduct_domain(req)!
	return update_subproduct_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_subproduct_domain(req UpdateSubProductReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateSubProductReq {
	id      string @[json: 'id']
	plan_id ?string @[json: 'planId']
	status  ?u8 @[json: 'status']
}

pub struct UpdateSubProductResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_subproduct_repo(mut ctx Context, req UpdateSubProductReq) !UpdateSubProductResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.plan_id {
			plan_id == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update TnSubProduct set up_expr where id == req.id
	}!
	return UpdateSubProductResp{
		msg: '订阅信息已更新'
	}
}
