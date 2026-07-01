module dbpool

const config_mysql = DatabaseConfig{
	type:     'mysql'
	host:     'mysql2.sqlpub.com'
	port:     3307
	username: 'vcore_test'
	password: 'wfo8wS7CylT0qIMg'
	dbname:   'vcore_test'
}

const config_pg = DatabaseConfig{
	type:     'pgsql'
	host:     'ep-wandering-king-akw206lc-pooler.c-3.us-west-2.aws.neon.tech'
	port:     5432
	username: 'neondb_owner'
	password: 'npg_U4j7sqBcgIMO'
	dbname:   'vcore_test'
}

fn test_acquire_mysql() {
	mut pool := new_db_pool(config_mysql) or { panic(err) }
	mut db, conn := pool.acquire() or { panic(err) }
	rows := db.execute('SELECT 1') or { panic(err) }
	dump(rows)
	defer {
		pool.release(conn) or {}
		pool.close()
	}
	assert true
}

fn test_acquire_raw_mysql() {
	mut pool := new_mysql_pool(config_mysql) or { panic(err) }
	mut db, conn := pool.acquire_raw() or { panic(err) }
	rows := db.exec('SELECT 1') or { panic(err) }
	dump(rows)
	mut p := &DatabasePoolable(pool) //必须这样转换,不然release/close方法无法调用
	defer {
		p.release(conn) or {}
		p.close()
	}
	assert true
}

// fn test_acquire_pg() {
// 	mut pool := new_db_pool(config_pg) or { panic(err) }
// 	mut db, conn := pool.acquire() or { panic(err) }
// 	rows := db.execute('SELECT 1') or { panic(err) }
// 	dump(rows)
// 	defer {
// 		pool.release(conn) or {}
// 		pool.close()
// 	}
// 	assert true
// }

// fn test_acquire_raw_pg() {
// 	mut pool := new_pgsql_pool(config_pg) or { panic(err) }
// 	mut db, conn := pool.acquire_raw() or { panic(err) }
// 	rows := db.exec('SELECT 1') or { panic(err) }
// 	dump(rows)
// 	mut p := &DatabasePoolable(pool) //必须这样转换,不然release/close方法无法调用
// 	defer {
// 		p.release(conn) or {}
// 		p.close()
// 	}
// 	assert true
// }
