module main

import pool

// ======================================
// MySQL Pool
// ======================================
@[heap]
pub struct MysqlPool {
mut:
	inner &pool.ConnectionPool
}

pub fn new_mysql_pool(conf DatabaseConfig) !&MysqlPool {
	create_conn := fn [conf] () !&pool.ConnectionPoolable {
		adapter := new_mysql_adapter(conf)!
		return adapter
	}

	cp := pool.new_connection_pool(create_conn, pool.ConnectionPoolConfig{
		max_conns:      conf.max_conns
		min_idle_conns: conf.min_idle_conns
		max_lifetime:   conf.max_lifetime
		idle_timeout:   conf.idle_timeout
		get_timeout:    conf.get_timeout
	})!

	return &MysqlPool{cp}
}

pub fn (mut p MysqlPool) acquire() !(DbAdapter, &pool.ConnectionPoolable) {
	mut conn := p.inner.get()!
	return conn as DbAdapter, conn
}

pub fn (mut p MysqlPool) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
}

pub fn (mut p MysqlPool) close() {
	p.inner.close()
}

// ======================================
// PostgreSQL Pool
// ======================================
@[heap]
pub struct PgPool {
mut:
	inner &pool.ConnectionPool
}

pub fn new_pg_pool(conf DatabaseConfig) !&PgPool {
	create_conn := fn [conf] () !&pool.ConnectionPoolable {
		adapter := new_pg_adapter(conf)!
		return adapter
	}

	cp := pool.new_connection_pool(create_conn, pool.ConnectionPoolConfig{
		max_conns:      conf.max_conns
		min_idle_conns: conf.min_idle_conns
		max_lifetime:   conf.max_lifetime
		idle_timeout:   conf.idle_timeout
		get_timeout:    conf.get_timeout
	})!

	return &PgPool{cp}
}

pub fn (mut p PgPool) acquire() !(DbAdapter, &pool.ConnectionPoolable) {
	mut conn := p.inner.get()!
	return conn as DbAdapter, conn
}

pub fn (mut p PgPool) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
}

pub fn (mut p PgPool) close() {
	p.inner.close()
}

// ======================================
// 动态创建数据库池
// ======================================
pub fn new_db_pool(conf DatabaseConfig) !DatabasePoolable {
	match conf.type.to_lower() {
		'mysql' { return new_mysql_pool(conf)! }
		'pgsql', 'postgres', 'postgresql' { return new_pg_pool(conf)! }
		else { return error('Unsupported db type: ${conf.type}') }
	}
}
