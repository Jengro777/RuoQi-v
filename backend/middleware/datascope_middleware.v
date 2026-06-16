module middleware

import veb
import structs { Context }
import adapter.datascope { ScopeConfig }

// datascope_middleware 数据范围中间件 — 将 ScopeConfig 构建为 ScopeContext 写入 ctx.scope_sc
pub fn datascope_middleware(cfg ScopeConfig) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [cfg] (mut ctx Context) bool {
			ctx.scope_sc = datascope.from_scope_config(cfg)
			return true
		}
		after:   false
	}
}
