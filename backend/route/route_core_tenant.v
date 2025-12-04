module route

import log
import structs
import service.core_api.core_tenant.authentication
import service.core_api.core_tenant.role
import service.core_api.core_tenant.role_permission

fn (mut app AliasApp) routes_core_tenant(mut ctx structs.Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 不需要token_jwt 认证
	app.register_routes_no_auth[authentication.Authentication, structs.Context](mut &authentication.Authentication{},
		'/core_tenant/authentication', mut ctx)

	// 必须通过token_jwt 认证
	app.register_routes_core[role.Role, structs.Context](mut &role.Role{}, '/core_tenant/role', mut
		ctx)
	app.register_routes_core[role_permission.RolePermission, structs.Context](mut &role_permission.RolePermission{},
		'/core_tenant/role_permission', mut ctx)
}
