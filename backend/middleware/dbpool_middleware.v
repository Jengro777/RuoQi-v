module middleware

import veb
import log
import time
import structs { Context }
import adapter.dbpool
import config

pub fn db_middleware(conn &dbpool.DatabasePoolable) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [conn] (mut ctx Context) bool {
			ctx.dbpool = unsafe { conn }
			return true
		}
	}
}

pub fn init_db_pool(doc &config.GlobalConfig) !&dbpool.DatabasePoolable {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	cp := dbpool.DatabaseConfig{
		type:           doc.dbconf.type
		host:           doc.dbconf.host
		port:           doc.dbconf.port.u32()
		username:       doc.dbconf.username
		password:       doc.dbconf.password
		dbname:         doc.dbconf.dbname
		max_conns:      doc.dbconf.max_conns
		min_idle_conns: doc.dbconf.min_idle_conns
		max_lifetime:   doc.dbconf.max_lifetime * time.minute
		idle_timeout:   doc.dbconf.idle_timeout * time.minute
		get_timeout:    doc.dbconf.get_timeout * time.second
	}

	mut conn := dbpool.new_db_pool(cp) or {
		log.error('数据库连接失败: ${config.config_toml()}: ${doc.dbconf.type} : ${err}')
		return err
	}
	log.debug(doc.dbconf.type + '数据库连接成功')
	return conn
}
