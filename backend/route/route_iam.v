module route

import log
import structs { Context }
import service.iam_service.iam_api { Iam }
import service.iam_service.iam_api.authentication { Authentication }
import service.iam_service.iam_api.user { User }
import service.iam_service.iam_api.profile { Profile }
import service.iam_service.iam_api.role { Role }
import service.iam_service.iam_api.permission { Permission }
import service.iam_service.iam_api.token { Token }

// =============================================================================
// IAM 路由注册
//
// 无需认证：auth（登录/注册/MFA）
// 需 IAM 认证：user / profile / role / permission / token
// =============================================================================

fn (mut app AliasApp) routes_iam(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 无需认证 —— 认证入口 + 注册 + MFA
	app.register_routes_no_auth[Iam, Context](mut &Iam{}, '/iam', mut ctx)
	app.register_routes_no_auth[Authentication, Context](mut &Authentication{}, '/iam/auth', mut
		ctx)

	// 需要 IAM 认证 —— 用户 / 角色 / 权限 / Token 管理
	app.register_routes_iam[User, Context](mut &User{}, '/iam/user', mut ctx)
	app.register_routes_iam[Profile, Context](mut &Profile{}, '/iam/profile', mut ctx)
	app.register_routes_iam[Role, Context](mut &Role{}, '/iam/role', mut ctx)
	app.register_routes_iam[Permission, Context](mut &Permission{}, '/iam/permission', mut ctx)
	app.register_routes_iam[Token, Context](mut &Token{}, '/iam/token', mut ctx)
}
