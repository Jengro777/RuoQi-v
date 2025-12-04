#!/usr/bin/env -S v run

import db.mysql

struct ConnectionPool {
mut:
	pool   chan mysql.DB
	config mysql.Config
}

// 全局实例（正确声明方式）
__global g_pool ConnectionPool

// 初始化连接池（程序启动时调用）
pub fn init_pool(config mysql.Config, pool_size int) {
	mut g := &g_pool
	g.config = config
	g.pool = chan mysql.DB{cap: pool_size}

	for _ in 0 .. pool_size {
		g.pool <- mysql.connect(config) or { panic(err) }
	}
}

// 获取连接（阻塞式）
pub fn acquire() mysql.DB {
	return <-g_pool.pool
}

// 释放连接
pub fn release(conn mysql.DB) {
	g_pool.pool <- conn
}

// 使用示例
fn main() {
	// 初始化配置
	config := mysql.Config{
		host:     'mysql2.sqlpub.com'
		port:     3307
		username: 'vcore_test'
		password: 'wfo8wS7CylT0qIMg'
		dbname:   'vcore_test'
	}

	// 初始化连接池（5个连接）
	init_pool(config, 5)

	// 获取连接
	mut conn := acquire()
	defer { release(conn) }

	// 执行查询
	rows := conn.exec('SELECT * FROM sys_users limit 1')!
	dump(rows)
}
