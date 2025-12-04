#!/usr/bin/env -S v run

import db.mysql
import db.pg
import pool
import time

// ======================================
// 数据库连接配置
// ======================================
pub struct DatabaseConfig {
pub mut:
	db_type    string // mysql | pgsql | postgres | postgresql
	host       string
	port       u32
	username   string
	password   string
	dbname     string
	ssl_verify bool @[default: false]

	//* pool 配置 */
	max_conns      int           = 100
	min_idle_conns int           = 10
	max_lifetime   time.Duration = 60 * time.minute
	idle_timeout   time.Duration = 30 * time.minute
	get_timeout    time.Duration = 3 * time.second
}

// ======================================
// 公共接口
// ======================================
pub interface DatabasePoolable {
mut:
	acquire() !(DbAdapter, &pool.ConnectionPoolable)
	release(conn &pool.ConnectionPoolable) !
	close()
}

// ======================================
// 统一数据库接口
// ======================================
pub interface DbAdapter {
mut:
	query(q string) ![]map[string]string
	execute(q string) !int
}

// ======================================
// MySQL Adapter
// ======================================
pub struct MysqlAdapter {
mut:
	conn mysql.DB
}

pub fn new_mysql_adapter(conf DatabaseConfig) !&MysqlAdapter {
	db := mysql.connect(mysql.Config{
		host:     conf.host
		port:     conf.port
		username: conf.username
		password: conf.password
		dbname:   conf.dbname
	})!
	return &MysqlAdapter{db}
}

pub fn (mut a MysqlAdapter) query(q string) ![]map[string]string {
	return a.conn.query(q)!.maps()
}

pub fn (mut a MysqlAdapter) execute(q string) !int {
	return a.conn.exec_none(q)
}

// ConnectionPoolable
pub fn (mut a MysqlAdapter) validate() !bool {
	a.conn.ping()!
	return true
}

pub fn (mut a MysqlAdapter) reset() ! {}

pub fn (mut a MysqlAdapter) close() ! {
	a.conn.close()!
}

// ======================================
// PostgreSQL Adapter
// ======================================
pub struct PgAdapter {
mut:
	conn pg.DB
}

pub fn new_pg_adapter(conf DatabaseConfig) !&PgAdapter {
	db := pg.connect(pg.Config{
		host:     conf.host
		port:     int(conf.port)
		user:     conf.username
		password: conf.password
		dbname:   conf.dbname
	})!
	return &PgAdapter{db}
}

fn get_val(opt ?string) string {
	return opt or { return '' }
}

pub fn (mut c PgAdapter) query(q string) ![]map[string]string {
	res := c.conn.exec_result(q)!
	mut rows := []map[string]string{}
	for row in res.rows {
		mut m := map[string]string{}
		for col, idx in res.cols {
			m[col] = get_val(row.vals[idx])
		}
		rows << m
	}
	return rows
}

pub fn (mut a PgAdapter) execute(q string) !int {
	res := a.conn.exec(q)!
	return res.len
}

// ConnectionPoolable
pub fn (mut a PgAdapter) validate() !bool {
	a.conn.exec('SELECT 1') or { return error('Postgres validation failed: ${err}') }
	return true
}

pub fn (mut a PgAdapter) reset() ! {}

pub fn (mut a PgAdapter) close() ! {
	a.conn.close()!
}

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
	match conf.db_type.to_lower() {
		'mysql' { return new_mysql_pool(conf)! }
		'pgsql', 'postgres', 'postgresql' { return new_pg_pool(conf)! }
		else { return error('Unsupported db type: ${conf.db_type}') }
	}
}

// _______________________

struct User {
	id string
}

fn main() {
	conf := DatabaseConfig{
		db_type:  'mysql' // 或 'pgsql'
		host:     '127.0.0.1'
		port:     3306
		username: 'root'
		password: 'mysql_123456'
		dbname:   'vcore'
	}

	mut d_pool := new_db_pool(conf) or { panic(err) }

	mut db, handler := d_pool.acquire() or { panic(err) }

	// query 测试
	rows := db.query('SELECT 1') or { panic(err) }
	println(rows)
	assert rows.len > 0

	// user := sql db {
	// 	select from User
	// }!
	// println(user)

	// 释放连接
	d_pool.release(handler)!

	// 关闭连接池
	d_pool.close()
}
