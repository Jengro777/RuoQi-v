module structs

import veb

pub struct Context {
	veb.Context
}

pub struct App {
	veb.Middleware[Context]
	veb.Controller
	veb.StaticHandler
}
