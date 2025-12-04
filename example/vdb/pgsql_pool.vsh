#!/usr/bin/env -S v run

import db.pg

// 简化配置
pub struct DatabaseConfig {
pub:
	db_type  string
	host     string
	port     u32
	username string
	password string
	dbname   string
}

// 统一接口
pub interface DbConnection {
	query(q string) ![]map[string]string
}

// PostgreSQL 连接实现
pub struct PgConnection {
mut:
	db pg.DB
}

pub fn new_pg_connection(conf DatabaseConfig) !&PgConnection {
	db := pg.connect(pg.Config{
		host:     conf.host
		port:     int(conf.port)
		user:     conf.username
		password: conf.password
		dbname:   conf.dbname
	})!
	return &PgConnection{db}
}

fn get_val(opt ?string) string {
	return opt or { return '' }
}

pub fn (c &PgConnection) query(q string) ![]map[string]string {
	res := c.db.exec_result(q)!
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

// 连接池相关
pub fn (c &PgConnection) validate() !bool {
	return true
}

pub fn (c &PgConnection) reset() ! {}

pub fn (c &PgConnection) close() ! {}

// 主函数测试
fn main() {
	conf := DatabaseConfig{
		db_type:  'postgresql'
		host:     'localhost'
		port:     5432
		username: 'root'
		password: 'pg_123456'
		dbname:   'postgres'
	}

	// 测试 PostgreSQL 连接
	mut conn := new_pg_connection(conf) or {
		println('Failed to connect: ${err}')
		return
	}

	result := conn.query('SELECT 1 as test_value') or {
		println('Query failed: ${err}')
		return
	}

	println('Result: ${result}')
}
