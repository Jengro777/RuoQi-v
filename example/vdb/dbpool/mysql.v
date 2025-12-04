module main

import db.mysql

// ======================================
// MySQL Adapter
// ======================================
pub struct MysqlAdapter {
mut:
	conn mysql.DB
}

pub fn new_mysql_adapter(conf DatabaseConfig) !&MysqlAdapter {
	mut config := mysql.Config{
		host:     conf.host
		port:     conf.port
		username: conf.username
		password: conf.password
		dbname:   conf.dbname
	}

	// SSL 配置
	if conf.ssl_verify {
		config.ssl_key = conf.ssl_key
		config.ssl_cert = conf.ssl_cert
		config.ssl_ca = conf.ssl_ca
		config.ssl_capath = conf.ssl_capath
		config.ssl_cipher = conf.ssl_cipher
		config.flag = conf.flag
	}

	db := mysql.connect(config)!
	return &MysqlAdapter{db}
}

pub fn (mut a MysqlAdapter) execute(q string) !int {
	return a.conn.exec_none(q)
}

// ConnectionPoolable
pub fn (mut a MysqlAdapter) validate() !bool {
	a.conn.ping()!
	return true
}

pub fn (mut a MysqlAdapter) reset() ! {}

pub fn (mut a MysqlAdapter) select() ! {}

pub fn (mut a MysqlAdapter) close() ! {
	a.conn.close()!
}
