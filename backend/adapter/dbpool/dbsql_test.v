module dbpool

const config = DatabaseConfig{
	type:     'mysql'
	host:     'mysql2.sqlpub.com'
	port:     3307
	username: 'vcore_test'
	password: 'wfo8wS7CylT0qIMg'
	dbname:   'vcore_test'
}

fn test_new_db_pool() {
	mut pool := new_db_pool(config)!
	defer { pool.close() }
	assert true
}

fn test_acquire() {
	mut pool := new_db_pool(config) or { panic(err) }
	_, conn := pool.acquire() or { panic(err) }
	pool.release(conn) or {}
	pool.close()
	assert true
}

fn test_acquire_raw() {
	mut pool := new_mysql_pool(config) or { panic(err) }
	db, conn := pool.acquire_raw() or { panic(err) }
	// 跳过 release/close: V pool ⚡ v_stable_sort bug
	rows := db.exec('SELECT 1') or { panic(err) }
	dump(rows)
	assert true
	_ := conn
}
