module route

import log
import structs
import service.core_api.core_admin.api
import service.core_api.core_admin.menu
import service.core_api.core_admin.oauthprovider
import service.core_api.core_admin.user

fn (mut app AliasApp) routes_core_admin(mut ctx structs.Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 必须通过token_jwt 认证
	app.register_routes_sys[api.Api, structs.Context](mut &api.Api{}, '/core_admin/api', mut
		ctx)
	app.register_routes_sys[menu.Menu, structs.Context](mut &menu.Menu{}, '/core_admin/menu', mut
		ctx)
	app.register_routes_sys[oauthprovider.OauthProvider, structs.Context](mut &oauthprovider.OauthProvider{},
		'/core_admin/oauthprovider', mut ctx)
	app.register_routes_sys[user.User, structs.Context](mut &user.User{}, '/core_admin/user', mut
		ctx)
}
