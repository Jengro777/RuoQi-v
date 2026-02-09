module db_api

import veb
import log
import common.api
import structs { Context }

@['/init/all_database'; get]
fn (app &Base) init_all(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	app.init_core(mut ctx)
	app.init_fms(mut ctx)
	app.init_job(mut ctx)
	app.init_mcms(mut ctx)
	app.init_pay(mut ctx)
	app.init_sys(mut ctx)

	log.debug('Database init_all success')
	return ctx.json(api.json_success_200('all database init Successfull'))
}
