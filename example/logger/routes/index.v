module routes

import veb
import structs { Context }

@['/'; get]
pub fn (mut app AliasApp) index(mut ctx Context) veb.Result {
	return ctx.json('req success')
}
