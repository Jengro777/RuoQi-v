#!/usr/bin/env -S v run

module main

import db.mysql
import pool
import time

// 数据库连接配置
struct DbConfig {
	type           string
	host           string
	port           u32
	username       string
	password       string
	dbname         string
	max_conns      int           = 100
	min_idle_conns int           = 10
	max_lifetime   time.Duration = 1 * time.hour
	idle_timeout   time.Duration = 30 * time.minute
	get_timeout    time.Duration = 5 * time.second
}

// 公共接口 - 使用泛型
pub interface DatabaseMysqlPool[T] {
mut:
	acquire() !(T, &pool.ConnectionPoolable)
	release(conn &pool.ConnectionPoolable) !
	close()
}

// 连接池结构体 - 添加泛型参数
@[heap]
struct DatabasePoolImpl[T] {
mut:
	inner &pool.ConnectionPool
}

// 创建新连接池 - 指定泛型类型
pub fn new_mysql_pool[T](config DbConfig) !&DatabaseMysqlPool[T] {
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
	pool_instance := &DatabasePoolImpl[T]{
		inner: inner_pool
	}
	return pool_instance
}

// 获取连接 - 使用泛型类型转换
pub fn (mut p DatabasePoolImpl[T]) acquire() !(T, &pool.ConnectionPoolable) {
	conn := p.inner.get()!
	// 安全类型转换

	return conn as mysql.DB, conn
}

// 释放连接
pub fn (mut p DatabasePoolImpl[T]) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
}

// 关闭连接池
pub fn (mut p DatabasePoolImpl[T]) close() {
	p.inner.close()
}

const config = DbConfig{
	host:     'mysql2.sqlpub.com'
	port:     3307
	username: 'vcore_test'
	password: 'wfo8wS7CylT0qIMg'
	dbname:   'vcore_test'
}

fn main() {
	mut db_pool := new_mysql_pool[mysql.DB](config)!
	defer { db_pool.close() }
	dump(db_pool)
	// assert typeof(db_pool).name == '&dbpool.DatabaseMysqlPool'
}
