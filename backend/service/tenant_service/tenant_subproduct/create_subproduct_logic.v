module tenant_subproduct

import veb
import log
import time
import rand
import json2 as json
import model { Context }
import model.schema_tenant { TnSubProduct }
import model.schema_platform { PfPlan, PfProduct }
import common.api as capi

// ═══ Handler ═══
@['/create_subproduct'; post]
pub fn (app &TenantSubProduct) create_subproduct_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateSubProductReq](ctx.req.data) or {
		return ctx.json(capi.json_error(code: capi.err_common_param_invalid, msg: err.msg()))
	}
	result := create_subproduct_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_subproduct_usecase(mut ctx Context, req CreateSubProductReq) !CreateSubProductResp {
	create_subproduct_domain(req)!
	return create_subproduct_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_subproduct_domain(req CreateSubProductReq) ! {
	if req.product_id == '' {
		return error('productId is required')
	}
	if req.plan_id == '' {
		return error('planId is required')
	}
}

// ═══ DTO ═══
pub struct CreateSubProductReq {
	product_id string @[json: 'productId']
	plan_id    string @[json: 'planId']
}

pub struct CreateSubProductResp {
	subproduct_id string @[json: 'subproductId']
	msg           string @[json: 'msg']
}

// ═══ Repository ═══
fn create_subproduct_repo(mut ctx Context, req CreateSubProductReq) !CreateSubProductResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	tenant_id := ctx.svc_iam.active_tenant_id

	// Verify product_id exists
	product_exists := sql db {
		select from PfProduct where id == req.product_id && del_flag == 0 limit 1
	} or { return error('Failed to verify product: ${err}') }
	if product_exists.len == 0 {
		return error('product not found')
	}

	// Verify plan_id exists
	plan_exists := sql db {
		select from PfPlan where id == req.plan_id && del_flag == 0 limit 1
	} or { return error('Failed to verify plan: ${err}') }
	if plan_exists.len == 0 {
		return error('plan not found')
	}

	subproduct := TnSubProduct{
		id: rand.uuid_v7()
		tenant_id: tenant_id
		product_id: req.product_id
		plan_id: req.plan_id
		status: 1
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert subproduct into TnSubProduct
	} or { return error('Failed to create subproduct: ${err}') }

	return CreateSubProductResp{
		subproduct_id: subproduct.id
		msg: '产品订阅成功'
	}
}
