module dbpool

import db.mysql
import pool
import time

pub struct DatabaseConfig {
pub mut:
	type       string
	host       string
	port       u32
	username   string
	password   string
	dbname     string
	ssl_verify bool @[default: false]
	flag       mysql.ConnectionFlag
	ssl_key    string
	ssl_cert   string
	ssl_ca     string
	ssl_capath string
	ssl_cipher string

	max_conns      int           = 100
	min_idle_conns int           = 10
	max_lifetime   time.Duration = 60 * time.minute
	idle_timeout   time.Duration = 30 * time.minute
	get_timeout    time.Duration = 3 * time.second
}

pub interface DatabasePoolable {
mut:
	acquire() !(mysql.DB, &pool.ConnectionPoolable)
	release(conn &pool.ConnectionPoolable) !
	close()
}

@[heap]
pub struct DatabasePool implements DatabasePoolable {
pub mut:
	inner &pool.ConnectionPool
}

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

pub fn (mut p DatabasePool) acquire() !(mysql.DB, &pool.ConnectionPoolable) {
	conn := p.inner.get()!
	return conn as mysql.DB, conn
}

pub fn (mut p DatabasePool) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
	return
}

pub fn (mut p DatabasePool) close() {
	p.inner.close()
}
