module iam_api

import structs { App, Context }
import veb
import log
import common.api { json_success_200 }

pub struct Iam {
	App
}

@['/'; get; post]
fn (app &Iam) index(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	return ctx.json(json_success_200('iam api success'))
}
