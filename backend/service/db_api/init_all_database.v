module db_api

import veb
import log
import common.api
import model { Context }

@['/init/all_database'; get]
pub fn (app &Database) init_all(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	app.init_base_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_base: ${err}'))
	}
	app.init_fms_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_fms: ${err}'))
	}
	app.init_job_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_job: ${err}'))
	}
	app.init_mcms_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_mcms: ${err}'))
	}
	app.init_pay_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_pay: ${err}'))
	}
	app.init_iam_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_iam: ${err}'))
	}
	app.init_platform_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_platform: ${err}'))
	}
	app.init_tenant_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_tenant: ${err}'))
	}
	app.init_workspace_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_workspace: ${err}'))
	}

	log.debug('Database init_all success')
	return ctx.json(api.json_success(data: 'all database init Successfull'))
}
