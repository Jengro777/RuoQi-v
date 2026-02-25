module pgsql_pool

import db.pg
import pool

// 创建新连接池
pub fn new_db_pool(config DatabaseConfig) !&DatabasePool {
	create_conn := fn [config] () !&pool.ConnectionPoolable {
		mut db := pg.connect(pg.Config{
			host:     config.host
			port:     config.port
			user:     config.username
			password: config.password
			dbname:   config.dbname
		})!
		return &db
	}

	pool_conf := pool.ConnectionPoolConfig{
		max_conns:      config.max_conns
		min_idle_conns: config.min_idle_conns
		max_lifetime:   config.max_lifetime
		idle_timeout:   config.idle_timeout
		get_timeout:    config.get_timeout
	}

	inner_pool := pool.new_connection_pool(create_conn, pool_conf)!
	pool_instance := &DatabasePool{
		inner: inner_pool
	}
	return pool_instance
}

// 获取连接
pub fn (mut p DatabasePool) acquire() !(pg.DB, &pool.ConnectionPoolable) {
	conn := p.inner.get()!
	// 安全类型转换
	return conn as pg.DB, conn
}

// 释放连接
pub fn (mut p DatabasePool) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
	return
}

// 关闭连接池
pub fn (mut p DatabasePool) close() {
	p.inner.close()
}
