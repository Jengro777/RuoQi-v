module route

import log
import structs { Context }
import handler.rest.sys_admin as user_ddd
import service.sys_admin_api { Admin } // 必须是路由模块内部声明的结构体
import service.sys_admin_api.user { User }
import service.sys_admin_api.token { Token }
import service.sys_admin_api.role { Role }
import service.sys_admin_api.role_permission { RolePermission }
import service.sys_admin_api.position { Position }
import service.sys_admin_api.menu { Menu }
import service.sys_admin_api.mfa { MFA }
import service.sys_admin_api.dictionary { Dictionary }
import service.sys_admin_api.dictionarydetail { DictionaryDetail }
import service.sys_admin_api.department { Department }
import service.sys_admin_api.configuration { Configuration }
import service.sys_admin_api.authentication { Authentication }
import service.sys_admin_api.api { Api }

fn (mut app AliasApp) routes_sys_admin(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	// 方式二：通过泛型的方式使用全局中间件，适合对多个控制器使用相同的中间件

	app.register_routes_no_auth[user_ddd.User, Context](mut &user_ddd.User{}, '/sys_admin/ddd/user', mut
		ctx)
	// 不需要token_jwt 认证
	app.register_routes_no_auth[Authentication, Context](mut &Authentication{}, '/sys_admin/auth', mut
		ctx)
	app.register_routes_no_auth[MFA, Context](mut &MFA{}, '/sys_admin/mfa', mut ctx)

	// 必须通过token_jwt 认证
	app.register_routes_sys[Admin, Context](mut &Admin{}, '/sys_admin', mut ctx)
	app.register_routes_sys[User, Context](mut &User{}, '/sys_admin/user', mut ctx)
	app.register_routes_sys[Token, Context](mut &Token{}, '/sys_admin/token', mut ctx)
	app.register_routes_sys[Role, Context](mut &Role{}, '/sys_admin/role', mut ctx)
	app.register_routes_sys[RolePermission, Context](mut &RolePermission{}, '/sys_admin/authority', mut
		ctx)
	app.register_routes_sys[Position, Context](mut &Position{}, '/sys_admin/position', mut
		ctx)
	app.register_routes_sys[Menu, Context](mut &Menu{}, '/sys_admin/menu', mut ctx)
	app.register_routes_sys[Dictionary, Context](mut &Dictionary{}, '/sys_admin/dictionary', mut
		ctx)
	app.register_routes_sys[DictionaryDetail, Context](mut &DictionaryDetail{}, '/sys_admin/dictionary_detail', mut
		ctx)
	app.register_routes_sys[Department, Context](mut &Department{}, '/sys_admin/department', mut
		ctx)
	app.register_routes_sys[Configuration, Context](mut &Configuration{}, '/sys_admin/configuration', mut
		ctx)
	app.register_routes_sys[Api, Context](mut &Api{}, '/sys_admin/api', mut ctx)
}
