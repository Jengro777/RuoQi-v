module tenant

import veb
import log
import model { Context }
import model.schema_tenant { TnMember, TnTenant }
import model.schema_platform { PfPortal, PfProduct }
import common.api

// ═══ Handler ═══
@['/my_tenants'; get]
pub fn (app &Tenant) find_my_tenants_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_my_tenants_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_my_tenants_usecase(mut ctx Context) ![]MyTenantPortals {
	find_my_tenants_domain(mut ctx)!
	return find_my_tenants_repo(mut ctx)
}

// ═══ Domain ═══
fn find_my_tenants_domain(mut ctx Context) ! {
	if ctx.svc_iam.user_id == '' {
		return error('user not authenticated')
	}
}

// ═══ DTO ═══
pub struct PortalBrief {
	product_id   string @[json: 'productId']
	product_code string @[json: 'productCode']
	product_name string @[json: 'productName']
	portal_id    string @[json: 'portalId']
	portal_code  string @[json: 'portalCode']
	portal_name  string @[json: 'portalName']
	portal_type  u8 @[json: 'portalType']
}

pub struct MyTenantPortals {
	tenant_id   string @[json: 'tenantId']
	tenant_name string @[json: 'tenantName']
	portals     []PortalBrief @[json: 'portals']
}

// ═══ Repository ═══
fn find_my_tenants_repo(mut ctx Context) ![]MyTenantPortals {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// 1. 查用户已入驻的产品+门户
	members := sql db {
		select from TnMember where user_id == ctx.svc_iam.user_id && status == 1 && del_flag == 0
	} or { return error('Failed to query member records: ${err}') }
	if members.len == 0 {
		return []MyTenantPortals{}
	}

	tenant_ids := members.map(it.tenant_id)
	product_ids := members.map(it.product_id)
	portal_ids := members.map(it.portal_id)

	// 2. 批量查租户、产品、门户
	tenants := sql db {
		select from TnTenant where id in tenant_ids && del_flag == 0
	} or { return error('Failed to query tenants: ${err}') }

	products := sql db {
		select from PfProduct where id in product_ids && del_flag == 0
	} or { return error('Failed to query products: ${err}') }

	portals := sql db {
		select from PfPortal where id in portal_ids && del_flag == 0
	} or { return error('Failed to query portals: ${err}') }

	// 3. 构建查找映射
	mut product_map := map[string]PfProduct{}
	for p in products {
		product_map[p.id] = p
	}
	mut portal_map := map[string]PfPortal{}
	for p in portals {
		portal_map[p.id] = p
	}

	// 4. 按租户分组 (O(n) — 先构建 tenant→members 映射)
	mut tenant_portals := map[string][]PortalBrief{}
	for m in members {
		pr := product_map[m.product_id] or { continue }
		pp := portal_map[m.portal_id] or { continue }
		tenant_portals[m.tenant_id] << PortalBrief{
			product_id: pr.id
			product_code: pr.product_code
			product_name: pr.product_name
			portal_id: pp.id
			portal_code: pp.portal_code
			portal_name: pp.portal_name
			portal_type: pp.portal_type
		}
	}

	mut result := []MyTenantPortals{}
	for t in tenants {
		portal_list := tenant_portals[t.id] or { []PortalBrief{} }
		result << MyTenantPortals{
			tenant_id: t.id
			tenant_name: t.name
			portals: portal_list
		}
	}
	return result
}
