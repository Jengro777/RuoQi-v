#!/usr/bin/env -S v run

import db.mysql
import time
import orm

fn db_mysql() !mysql.DB {
	mut mysql_config := mysql.Config{
		host:     'mysql2.sqlpub.com'
		port:     3307
		username: 'vcore_test'
		password: 'wfo8wS7CylT0qIMg'
		dbname:   'vcore_test'
	}
	mut conn := mysql.connect(mysql_config) or { return err }
	return conn
}

@[table: 'sys_users']
struct User_3 {
pub:
	id         string     @[immutable; primary; sql: 'id'; sql_type: 'VARCHAR(255)'; unique]
	name       string     @[immutable; sql: 'username'; sql_type: 'VARCHAR(255)'; unique]
	created_at ?time.Time @[omitempty; sql_type: 'TIMESTAMP']
	updated_at time.Time  @[omitempty; sql_type: 'TIMESTAMP']
}

fn main() {
	mut db := db_mysql() or { panic('failed to connect to database') }
	defer { db.close() or {} }

	mut result := sql db {
		select from User_3
	} or { panic(err) }
	dump(result)

	mut user := orm.new_query[User_3](db)
	result1 := user.select('id', 'username')!.query()!
	dump(result1)
	result2 := user.where('id != ?', '001')!.count()!
	dump(result2)
}
