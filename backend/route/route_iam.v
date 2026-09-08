module route

import log
import model { Context }
import service.iam_service.iam_api { Iam }
import service.iam_service.iam_api.authentication { Authentication }
import service.iam_service.iam_api.user { User }
import service.iam_service.iam_api.profile { Profile }
import service.iam_service.iam_api.token { Token }
import service.iam_service.iam_api.apikey { ApiKey }
import service.iam_service.iam_api.tenant { Tenant }

// =============================================================================
// IAM 路由注册
//
// 无需认证：auth（登录/注册/MFA）
// 仅认证（自服务）：profile / token / tenant — 已登录即可访问
// 身份+租户隔离：tenants — 租户成员校验 + datascope（未来会员端 API 用此模式）
// 全量认证+授权：user / apikey — 需 workspace 权限（admin 通过 workspace_admin 角色获得 all）
// =============================================================================

fn (mut app AliasApp) routes_iam(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 无需认证 —— 认证入口 + 注册 + MFA
	app.register_routes_no_auth[Iam, Context](mut &Iam{}, '/iam', mut ctx)
	app.register_routes_no_auth[Authentication, Context](mut &Authentication{}, '/iam/auth', mut ctx)

	// 仅认证（自服务）—— 已登录即可访问，不检查 workspace 权限
	app.register_routes_authenticated[Profile, Context](mut &Profile{}, '/iam/profile', mut ctx)
	app.register_routes_authenticated[Token, Context](mut &Token{}, '/iam/token', mut ctx)
	app.register_routes_authenticated[Tenant, Context](mut &Tenant{}, '/iam/tenant', mut ctx)

	// 全量认证+授权 —— 需要 workspace 权限
	app.register_routes_platform[User, Context](mut &User{}, '/iam/user', mut ctx)
	app.register_routes_platform[ApiKey, Context](mut &ApiKey{}, '/iam/apikey', mut ctx)
}
