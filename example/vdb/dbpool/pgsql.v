module main

import db.pg

// ======================================
// PostgreSQL Adapter
// ======================================
pub struct PgAdapter {
mut:
	conn pg.DB
}

pub fn new_pg_adapter(conf DatabaseConfig) !&PgAdapter {
	db := pg.connect(pg.Config{
		host:     conf.host
		port:     int(conf.port)
		user:     conf.username
		password: conf.password
		dbname:   conf.dbname
	})!
	return &PgAdapter{db}
}

fn get_val(opt ?string) string {
	return opt or { return '' }
}

pub fn (mut c PgAdapter) query(q string) ![]map[string]string {
	res := c.conn.exec_result(q)!
	mut rows := []map[string]string{}
	for row in res.rows {
		mut m := map[string]string{}
		for col, idx in res.cols {
			m[col] = get_val(row.vals[idx])
		}
		rows << m
	}
	return rows
}

pub fn (mut a PgAdapter) execute(q string) !int {
	res := a.conn.exec(q)!
	return res.len
}

// ConnectionPoolable
pub fn (mut a PgAdapter) validate() !bool {
	a.conn.exec('SELECT 1') or { return error('Postgres validation failed: ${err}') }
	return true
}

pub fn (mut a PgAdapter) reset() ! {}

pub fn (mut a PgAdapter) close() ! {
	a.conn.close()!
}
