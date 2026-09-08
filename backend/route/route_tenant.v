module route

import log
import model { Context }
import service.tenant_service.tenant_subproduct { TenantSubProduct }
import service.tenant_service.tenant_member { TenantMember }
import service.tenant_service.tenant_invoice { TenantInvoice }
import service.tenant_service.tenant_config { TenantConfig }

// =============================================================================
// Tenant 路由注册 — 租户自服务门户（scoped 认证）
//
// scoped 中间件：JWT 身份 + tn_member 校验 + tenant_id datascope 隔离
// 用户需携带 X-Tenant-ID / X-Product-ID / X-Portal-ID 请求头
// =============================================================================

fn (mut app AliasApp) routes_tenant(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 产品订阅
	app.register_routes_scoped[TenantSubProduct, Context](mut &TenantSubProduct{}, '/tenant/subproduct', mut ctx)

	// 成员管理
	app.register_routes_scoped[TenantMember, Context](mut &TenantMember{}, '/tenant/member', mut ctx)

	// 账单查看
	app.register_routes_scoped[TenantInvoice, Context](mut &TenantInvoice{}, '/tenant/invoice', mut ctx)

	// 租户配置
	app.register_routes_scoped[TenantConfig, Context](mut &TenantConfig{}, '/tenant/config', mut ctx)
}
