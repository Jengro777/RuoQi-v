module middleware

import veb
import log
import time
import structs { Context }
import adapter.dbpool
import config

// 独立中间件生成函数
pub fn db_middleware(conn &dbpool.DatabasePool) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [conn] (mut ctx Context) bool {
			ctx.dbpool = unsafe { conn } //分配到堆上，需要使用 unsafe
			return true // 返回 true 表示继续处理请求
		}
	}
}

// 初始化数据库连接池
pub fn init_db_pool(doc &config.GlobalConfig) !&dbpool.DatabasePool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut config_db := dbpool.DatabaseConfig{
		host:     doc.dbconf.host
		port:     doc.dbconf.port.u32()
		username: doc.dbconf.username
		password: doc.dbconf.password
		dbname:   doc.dbconf.dbname
		// ssl_ca:   doc.value('dbconf.ssl_ca').string()
		// flag: .client_ssl | .client_ssl_verify_server_cert
		//*pool 配置*/
		max_conns:      doc.dbconf.max_conns
		min_idle_conns: doc.dbconf.min_idle_conns
		max_lifetime:   doc.dbconf.max_lifetime * time.minute
		idle_timeout:   doc.dbconf.idle_timeout * time.minute
		get_timeout:    doc.dbconf.get_timeout * time.second
	}

	if doc.dbconf.ssl_verify == true {
		config_db.flag = .client_ssl | .client_ssl_verify_server_cert
		config_db.ssl_key = doc.dbconf.ssl_key
		config_db.ssl_cert = doc.dbconf.ssl_cert
		config_db.ssl_ca = doc.dbconf.ssl_ca
		config_db.ssl_capath = doc.dbconf.ssl_capath
		config_db.ssl_cipher = doc.dbconf.ssl_cipher
	}
	// log.debug('${config_db}')
	mut conn := dbpool.new_db_pool(config_db) or {
		log.error('Mysql/TiDB数据库连接失败,请检查配置文件: ${config.config_toml()}: ${doc.dbconf} : ${err}')
		return err
	}
	// log.debug('${conn}')
	log.debug(doc.dbconf.type + '数据库连接成功')
	return conn
}
