module middleware

import veb
import log
import structs { Context }
import adapter.cache_pool
import config

// 独立中间件生成函数
pub fn cache_middleware(conn &cache_pool.CachePool) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [conn] (mut ctx Context) bool {
			ctx.cache_pool = unsafe { conn }
			return true // 返回 true 表示继续处理请求
		}
	}
}

// 初始化Redis缓存连接池
pub fn init_cache_pool(doc &config.GlobalConfig) !&cache_pool.CachePool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut config_redis := cache_pool.CacheConfig{
		host:     doc.redis.host
		port:     doc.redis.port.u16()
		password: doc.redis.password
	}

	// log.debug('${config_redis}')
	mut conn := cache_pool.new_cache_pool(config_redis) or {
		log.error('缓存连接失败,请检查配置文件: ${config.config_toml()}: ${doc.redis} : ${err}')
		return err
	}
	// log.debug('${conn}')
	// log.debug(doc.conn.type + '缓存连接成功')
	return conn
}
