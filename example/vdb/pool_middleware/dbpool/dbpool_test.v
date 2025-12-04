module dbpool

const config = DatabaseConfig{
	host:     'mysql2.sqlpub.com'
	port:     3307
	username: 'vcore_test'
	password: 'wfo8wS7CylT0qIMg'
	dbname:   'vcore_test'
}

fn test_new_db_pool() {
	mut db_pool := new_db_pool(config)!
	defer { db_pool.close() }
	assert typeof(db_pool).name == '&dbpool.DatabasePool'
}

fn test_acquire() {
	mut db_pool := new_db_pool(config) or { panic(err) }
	mut db, conn := db_pool.acquire() or { panic(err) }

	defer {
		db_pool.release(conn) or { panic(err) }
		db_pool.close()
	}

	query := 'SELECT 1'
	rows := db.exec(query) or { panic(err) }
	dump(rows)
	assert typeof(rows).name in ['[]mysql.Row', '[]pg.Row', '[]sqlite.Row']
}
