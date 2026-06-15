module route

import log
import structs { Context }

// 根据条件编译，选择运行的服务
pub fn (mut app AliasApp) setup_conditional_routes(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	$if fms ? {
		log.warn('routes_ifdef - Fms')
	}
	$if iam ? {
		log.warn('routes_ifdef - Core')
		app.routes_iam(mut ctx)
		app.routes_workspace(mut ctx)
	}
	$if job ? {
		log.warn('routes_ifdef - Job')
	}
	$if mcms ? {
		log.warn('routes_ifdef - Mcms')
	}
	$if pay ? {
		log.warn('routes_ifdef - Pay')
	}
	$if platform ? {
		log.warn('routes_ifdef - Sys')
		app.routes_platform(mut ctx)
	} $else {
		log.warn('routes_ifdef - All')
		app.routes_db(mut ctx)
		app.routes_sys_base(mut ctx)
		app.routes_iam(mut ctx)
		app.routes_platform(mut ctx)
		app.routes_workspace(mut ctx)
	}
}
