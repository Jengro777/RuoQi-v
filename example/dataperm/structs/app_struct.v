module structs

import veb
import data_perm

pub struct Context {
	veb.Context
pub mut:
	data_perm ?data_perm.DataPermContext
}

pub struct App {
	veb.Middleware[Context]
}
