#!/usr/bin/env -S v run

import veb

struct Context {
	veb.Context
}

struct App {
	veb.Middleware[Context]
}

fn (mut app App) index(mut ctx Context) veb.Result {
	return ctx.json('index succcess')
}

fn main() {
	port := 9008
	mut app := &App{}
	app.use(authority_middleware())
	veb.run[App, Context](mut app, port)
}

fn authority_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: authority_jwt_verify
		after:   false
	}
}

fn authority_jwt_verify(mut ctx Context) bool {
	// ctx.res.set_status(.unauthorized)
	// ctx.res.header.set(.content_type, 'application/json')
	ctx.send_response_to_client('application/json', 'send_response_to_client unauthorized')
	// ctx.request_error('request_error')
	// ctx.server_error('server_error')

	ctx.error('Bad credentials')
	return false
}
