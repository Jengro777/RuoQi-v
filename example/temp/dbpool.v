module main

import db.mysql
import db.pg
import pool
import time

// ================================
// 数据库类型
// ================================
pub enum DbType {
	mysql
	pgsql
}

// ================================
// 数据库配置
// ================================
pub struct DatabaseConfig {
pub mut:
	type       DbType
	host       string
	port       u32
	username   string
	password   string
	dbname     string
	ssl_verify bool @[default: false] // #设置为true时，验证ssl证书
	flag       mysql.ConnectionFlag
	ssl_key    string
	ssl_cert   string
	ssl_ca     string
	ssl_capath string
	ssl_cipher string

	//*pool 配置*/
	// 最大连接数：连接池允许同时打开的最大数据库连接数
	// 超过此数量时，新请求需要等待空闲连接
	max_conns int = 100
	// 最小空闲连接数：连接池始终保持的最小空闲连接数量
	// 用于减少新连接创建开销，提高响应速度
	min_idle_conns int = 10
	// 连接最大生命周期：连接在被关闭前可存活的最长时间
	// 防止长时间使用导致的内存泄漏或状态不一致
	// 推荐设置为小于数据库服务器的连接超时时间
	max_lifetime time.Duration = 60 * time.minute
	// 空闲连接超时时间：连接在空闲池中保留的最长时间
	// 超过此时间未使用的连接将被自动关闭
	// 平衡资源利用率和连接新鲜度
	idle_timeout time.Duration = 30 * time.minute
	// 获取连接超时时间：等待连接分配的最大时间
	// 当所有连接都在使用中且达到max_conns时
	// 超时将返回错误而非无限等待
	get_timeout time.Duration = 3 * time.second
}

// 公共接口
pub interface DatabasePoolable {
mut:
	acquire() !(&pool.ConnectionPoolable, &pool.ConnectionPoolable)
	release(conn &pool.ConnectionPoolable) !
	close()
}

// ================================
// 动态数据库连接池
// ================================
@[heap]
pub struct DatabasePool implements DatabasePoolable {
pub mut:
	inner &pool.ConnectionPool
	type  DbType
}

// ================================
// 创建动态连接池
// ================================
pub fn new_db_pool(conf DatabaseConfig) !&DatabasePool {
	create_conn := fn [conf] () !&pool.ConnectionPoolable {
		if conf.type == .mysql {
			mut db := mysql.connect(mysql.Config{
				host:     conf.host
				port:     u32(conf.port)
				username: conf.username
				password: conf.password
				dbname:   conf.dbname
			})!
			return &db
		} else {
			mut db := pg.connect(pg.Config{
				host:     conf.host
				port:     int(conf.port)
				user:     conf.username
				password: conf.password
				dbname:   conf.dbname
			})!
			return &db
		}
	}

	inner := pool.new_connection_pool(create_conn, pool.ConnectionPoolConfig{
		max_conns: conf.max_conns
	})!

	return &DatabasePool{
		inner: inner
		type:  conf.type
	}
}

// ================================
// 获取连接
// ================================
pub fn (mut p DatabasePool) acquire() !(&pool.ConnectionPoolable, &pool.ConnectionPoolable) {
	conn := p.inner.get()!
	return conn, conn
}

// ================================
// 释放连接
// ================================
pub fn (mut p DatabasePool) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
}

// ================================
// 关闭连接池
// ================================
pub fn (mut p DatabasePool) close() {
	p.inner.close()
}
