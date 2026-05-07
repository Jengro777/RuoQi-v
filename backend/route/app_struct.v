module route

import veb
import structs { App }

pub struct AliasApp {
	App
}

// init_server stores the veb server handle for graceful shutdown.
pub fn (mut app AliasApp) init_server(server &veb.Server) {
	app.server = server
}

// request_shutdown notifies the main app lifecycle once without blocking.
pub fn (app &AliasApp) request_shutdown() {
	app.shutdown_signal.try_push(true)
}
