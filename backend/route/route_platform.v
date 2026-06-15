module route

import log
import structs { Context }
import service.platform_service.platform_api { PlatformApi }
import service.platform_service.platform_menu { PlatformMenu }
import service.platform_service.platform_dictionary { PlatformDictionary }
import service.platform_service.platform_configuration { PlatformConfiguration }

// =============================================================================
// Platform 路由注册 — 平台级管理（Sys 认证）
// =============================================================================

fn (mut app AliasApp) routes_platform(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// API 管理
	app.register_routes_platform[PlatformApi, Context](mut &PlatformApi{}, '/platform/api', mut ctx)

	// 菜单管理
	app.register_routes_platform[PlatformMenu, Context](mut &PlatformMenu{}, '/platform/menu', mut
		ctx)

	// 数据字典
	app.register_routes_platform[PlatformDictionary, Context](mut &PlatformDictionary{},
		'/platform/dictionary', mut ctx)

	// 系统配置
	app.register_routes_platform[PlatformConfiguration, Context](mut &PlatformConfiguration{},
		'/platform/configuration', mut ctx)
}
