module middleware

import veb
import log
import api { Context }
import dbpool

pub fn init_db_pool() !&dbpool.DatabasePool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut config_db := dbpool.DatabaseConfig{
		host:     'mysql2.sqlpub.com'
		port:     3307
		username: 'vcore_test'
		password: 'wfo8wS7CylT0qIMg'
		dbname:   'vcore_test'
	}

	mut conn := dbpool.new_db_pool(config_db) or {
		log.error('error: ${err}')
		return err
	}
	log.debug('success')
	return conn
}

pub fn db_middleware(conn &dbpool.DatabasePool) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [conn] (mut ctx Context) bool {
			ctx.dbpool = conn
			return true
		}
	}
}
