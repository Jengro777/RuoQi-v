module main

import veb
import log
import structs
import routes

const cors_origin = ['*', 'xx.com']

pub fn app_start() {
	log.info('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut app := &routes.AliasApp{}
	app.register_routes()

	app.use(veb.cors[structs.Context](veb.CorsOptions{
		origins:         cors_origin
		allowed_methods: [.get, .head, .patch, .put, .post, .delete, .options]
	}))

	port := 9009
	veb.run_at[routes.AliasApp, structs.Context](mut app,
		host:               ''
		port:               port
		family:             .ip6
		timeout_in_seconds: 30
	) or { panic(err) }
}
