#!/usr/bin/env -S v run

import db.mysql
import time

@[table: 'sys_users']
struct User {
pub:
	id         string     @[immutable; primary; sql: 'id'; sql_type: 'VARCHAR(255)'; unique]
	name       string     @[immutable; sql: 'username'; sql_type: 'VARCHAR(255)'; unique]
	created_at ?time.Time @[omitempty; sql_type: 'TIMESTAMP']
	updated_at time.Time  @[omitempty; sql_type: 'TIMESTAMP']
}

fn main() {
	mut pool := db_pool()
	defer { pool.close() }

	{
		mut pb := pool.acquire() or { panic(err) } //获取一个连接
		dump(pb)
		mut result := sql pb {
			select from User
		} or { panic(err) }
		dump(result)
		defer { pool.release(pb) } //释放连接
	}
	{
		mut pb2 := pool.acquire() or { panic(err) } //获取一个连接
		dump(pb2)
		mut result2 := sql pb2 {
			select from User
		} or { panic(err) }
		dump(result2)
		defer { pool.release(pb2) } //释放连接
	}
}

fn db_pool() mysql.ConnectionPool {
	config := mysql.Config{
		host:     'mysql2.sqlpub.com'
		port:     3307
		username: 'vcore_test'
		password: 'wfo8wS7CylT0qIMg'
		dbname:   'vcore_test'
		// timeout:  30 * time.second // 连接超时设置[10](@ref)
	}
	// 2. 初始化连接池（建议大小10-20）
	mut pool := mysql.new_connection_pool(config, 10) or { panic('Failed to create pool: ${err}') }
	dump(pool)

	return pool
}
