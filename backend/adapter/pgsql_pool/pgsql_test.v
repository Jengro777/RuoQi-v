module pgsql_pool

const config = DatabaseConfig{
	host:     'ep-wandering-king-akw206lc-pooler.c-3.us-west-2.aws.neon.tech'
	port:     5432
	username: 'neondb_owner'
	password: 'npg_U4j7sqBcgIMO'
	dbname:   'vcore_test'
}

fn test_new_db_pool() {
	mut db_pool := new_db_pool(config)!
	defer { db_pool.close() }
	// dump(db_pool)
	assert typeof(db_pool).name == '&pgsql_pool.DatabasePool'
		|| typeof(db_pool).name == '&pg_pool.DatabasePool'
}

fn test_acquire() {
	mut db_pool := new_db_pool(config) or { panic(err) }
	// 通过具体实现类型使用连接池
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
