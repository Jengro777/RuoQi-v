module iam_api

import model { App, Context }
import veb
import log
import common.api

pub struct Iam {
	App
}

@['/'; get; post]
fn (app &Iam) index(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	return ctx.json(api.json_success(data: 'iam api success'))
}
