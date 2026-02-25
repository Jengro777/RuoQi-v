module dbpool

import db.mysql
import pool


// 创建新连接池
pub fn new_db_pool(config DatabaseConfig) !&DatabasePool {
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
pub fn (mut p DatabasePool) acquire() !(mysql.DB, &pool.ConnectionPoolable) {
	conn := p.inner.get()!
	// 安全类型转换
	return conn as mysql.DB, conn
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
