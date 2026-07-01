module dbpool

import orm
import pool
import db.mysql
import db.pg

pub fn new_db_pool(config DatabaseConfig) !&DatabasePoolable {
	match config.type {
		'mysql' {
			p := new_mysql_pool(config)!
			return &DatabasePoolable(p)
		}
		'pgsql' {
			p := new_pgsql_pool(config)!
			return &DatabasePoolable(p)
		}
		else {
			return error('unsupported db_type: ${config.type}')
		}
	}
}

fn new_pgsql_pool(config DatabaseConfig) !&DatabasePool[pg.DB] {
	create_conn := fn [config] () !&pool.ConnectionPoolable {
		mut db := pg.connect(pg.Config{
			host:     config.host
			port:     int(config.port)
			user:     config.username
			password: config.password
			dbname:   config.dbname
		})!
		return &db
	}
	pool_conf := pool.ConnectionPoolConfig{
		max_conns:      config.max_conns
		min_idle_conns: config.min_idle_conns
	}
	inner_pool := pool.new_connection_pool(create_conn, pool_conf)!
	return &DatabasePool[pg.DB]{
		inner: inner_pool
	}
}

fn new_mysql_pool(config DatabaseConfig) !&DatabasePool[mysql.DB] {
	create_conn := fn [config] () !&pool.ConnectionPoolable {
		mut db := mysql.connect(mysql.Config{
			host:     config.host
			port:     config.port
			username: config.username
			password: config.password
			dbname:   config.dbname
		})!
		return &db
	}
	pool_conf := pool.ConnectionPoolConfig{
		max_conns:      config.max_conns
		min_idle_conns: config.min_idle_conns
	}
	inner_pool := pool.new_connection_pool(create_conn, pool_conf)!
	return &DatabasePool[mysql.DB]{
		inner: inner_pool
	}
}

// acquire 返回 orm.Connection，数据库无关，用于 sql db { ... } 块。
pub fn (mut p DatabasePool[T]) acquire() !(orm.Connection, &pool.ConnectionPoolable) {
	raw_conn := p.inner.get()!
	raw := raw_conn as T
	return raw, raw_conn
}

// acquire_raw 返回具体类型 T，可用于调用驱动特有方法（如 db.exec()）。
pub fn (mut p DatabasePool[T]) acquire_raw() !(T, &pool.ConnectionPoolable) {
	raw_conn := p.inner.get()!
	raw := raw_conn as T
	return raw, raw_conn
}

pub fn (mut p DatabasePool[T]) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
}

pub fn (mut p DatabasePool[T]) close() {
	p.inner.close()
}
