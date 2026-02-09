module main

struct User {
	id string
}

fn test_mysql() ! {
	conf := DatabaseConfig{
		type:     'mysql' // 或 'pgsql'
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

fn test_pgsql() ! {
	conf := DatabaseConfig{
		type:     'pgsql' // 或 'pgsql'
		host:     '127.0.0.1'
		port:     5432
		username: 'root'
		password: 'pg_123456'
		dbname:   'postgres'
	}

	mut d_pool := new_db_pool(conf) or { panic(err) }

	mut db, handler := d_pool.acquire() or { panic(err) }

	// query 测试
	rows := db.query('SELECT 1 as test_value') or { panic(err) }
	println(rows)
	assert rows.len > 0

	// 释放连接
	d_pool.release(handler)!

	// 关闭连接池
	d_pool.close()
}

fn main() {
	test_mysql()!
	test_pgsql()!
}
