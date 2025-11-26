module structs

import veb
import common.jwt { JwtPayload }
import adapter.dbpool
import config
import i18n

pub struct Context {
	veb.Context
pub mut:
	dbpool      &dbpool.DatabasePool
	config      &config.GlobalConfig
	jwt_payload ?JwtPayload
	svc_ctx     ServiceContext

	i18n       &i18n.I18nStore   = unsafe { nil }
	extra_i18n map[string]string = map[string]string{}
}

pub struct App {
	veb.Middleware[Context]
	veb.Controller
	veb.StaticHandler
pub mut:
	started chan bool // 用于通知应用程序已成功启动
}

pub struct ServiceContext {
pub mut:
	user_id   string
	tenant_id string
}
