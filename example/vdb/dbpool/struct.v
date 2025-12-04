module main

import pool
import time
import db.mysql

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
	create(table string, data map[string]any) !
	insert(table string, data map[string]any) !int
	update(table string, data map[string]any, where string) !int
	delete(table string, where string) !int
	select_one(table string, where string) !map[string]string
	select_all(table string, where string) ![]map[string]string
}

// ======================================
// 数据库连接配置
// ======================================

pub struct DatabaseConfig {
pub mut:
	type       string
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
