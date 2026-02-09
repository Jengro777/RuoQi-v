module middleware

import veb
import structs { Context }
import config

// 配置中间件 - 将全局配置注入请求上下文
pub fn config_middle(conf &config.GlobalConfig) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [conf] (mut ctx Context) bool {
			ctx.config = conf
			return true
		}
	}
}
