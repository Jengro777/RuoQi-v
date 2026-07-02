module pgsql_pool

import db.pg
import pool

// 创建新连接池
pub fn new_db_pool_with_connect(config DatabaseConfig) !&DatabasePool {
	create_conn := fn [config] () !&pool.ConnectionPoolable {
		mut db := pg.connect(pg.Config{
			host:     config.host
			port:     config.port
			user:     config.username
			password: config.password
			dbname:   config.dbname
		})!
		return db
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

// 创建新连接池
pub fn new_db_pool_with_conninfo(config DatabaseConfig) !&DatabasePool {
	create_conn := fn [config] () !&pool.ConnectionPoolable {
		mut conninfo := 'host=${config.host} port=${config.port} user=${config.username} dbname=${config.dbname}'
		if config.password.len > 0 {
			conninfo += ' password=${config.password}'
		}

		// 添加 SSL 参数到连接字符串
		if config.ssl_ca.len > 0 {
			conninfo += ' sslrootcert=${config.ssl_ca}'
		}
		if config.ssl_cert.len > 0 {
			conninfo += ' sslcert=${config.ssl_cert}'
		}
		if config.ssl_key.len > 0 {
			conninfo += ' sslkey=${config.ssl_key}'
		}
		if config.ssl_capath.len > 0 {
			conninfo += ' sslcapath=${config.ssl_capath}'
		}
		if config.ssl_cipher.len > 0 {
			conninfo += ' sslcipher=${config.ssl_cipher}'
		}
		if config.ssl_verify {
			conninfo += ' sslmode=require'
		}

		// 使用 pg.connect_with_conninfo() 构建包含 SSL 参数的连接字符串
		// 这是 pg 模块唯一支持 SSL 的方法
		mut db := pg.connect_with_conninfo(conninfo)!
		return db
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
