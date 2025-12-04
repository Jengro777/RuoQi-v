module sys_admin

import veb
import log
import common.api { json_success_200 }
import structs { Context }

@['/'; get; post]
fn (app &Admin) index(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	return ctx.json(json_success_200('admin success'))
}
