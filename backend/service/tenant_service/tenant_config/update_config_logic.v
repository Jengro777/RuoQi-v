module tenant_config

import veb
import log
import time
import rand
import json2 as json
import model { Context }
import model.schema_tenant { TnConfig }
import common.api as capi

// ═══ Handler ═══
@['/update_config'; post]
pub fn (app &TenantConfig) update_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateConfigReq](ctx.req.data) or {
		return ctx.json(capi.json_error_400(err.msg()))
	}
	result := update_config_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_config_usecase(mut ctx Context, req UpdateConfigReq) !UpdateConfigResp {
	update_config_domain(req)!
	return update_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_config_domain(req UpdateConfigReq) ! {
	if req.key == '' {
		return error('key is required')
	}
	if req.value == '' {
		return error('value is required')
	}
}

// ═══ DTO ═══
pub struct UpdateConfigReq {
	key         string @[json: 'key']
	value       string @[json: 'value']
	category    string @[json: 'category']
	description string @[json: 'description']
}

pub struct UpdateConfigResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_config_repo(mut ctx Context, req UpdateConfigReq) !UpdateConfigResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	tenant_id := ctx.svc_iam.active_tenant_id
	product_id := ctx.svc_iam.active_subproduct_id

	// upsert: 先查是否存在
	existing := sql db {
		select from TnConfig where tenant_id == tenant_id && product_id == product_id && key == req.key
		&& del_flag == 0 limit 1
	} or { return error('Failed to query config: ${err}') }

	if existing.len > 0 {
		// vfmt off
		up_expr :=
			sql
		{
			value == req.value, category == req.category, description == req.description, updater_id == ctx.svc_iam.user_id, updated_at == time.now()
		}
		// vfmt on
		sql db {
			dynamic update TnConfig set up_expr where id == existing[0].id
		}!
	} else {
		config := TnConfig{
			id: rand.uuid_v7()
			tenant_id: tenant_id
			product_id: product_id
			key: req.key
			value: req.value
			category: req.category
			description: req.description
			status: 1
			creator_id: ctx.svc_iam.user_id
			updater_id: ctx.svc_iam.user_id
			created_at: time.now()
			updated_at: time.now()
		}
		sql db {
			insert config into TnConfig
		}!
	}
	return UpdateConfigResp{
		msg: '配置已更新'
	}
}
