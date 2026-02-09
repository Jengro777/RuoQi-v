#!/usr/bin/env -S v run

import db.sqlite
import time
import orm

@[table: 'sys_user']
struct User_2 {
pub:
	id         string     @[immutable; primary; sql: 'id'; sql_type: 'VARCHAR(255)'; unique]
	name       ?string    @[immutable; sql: 'name'; sql_type: 'VARCHAR(255)'; unique]
	nickname   string     @[sql: 'nickname'; sql_type: 'VARCHAR(255)']
	created_at time.Time  @[omitempty; sql_type: 'TIMESTAMP']
	updated_at ?time.Time @[default: new; omitempty; sql_type: 'TIMESTAMP']
}

fn main() {
	mut db := sqlite.connect(':memory:')!
	defer { db.close() or {} }

	users1 := User_2{
		id:         '1'
		name:       'Jengro'
		nickname:   'nickname_jengro'
		created_at: time.now()
		updated_at: time.now()
	}

	users2 := User_2{
		id:         '2'
		name:       'Dev'
		nickname:   'nickname_dev'
		created_at: time.now()
		updated_at: time.now()
	}

	sql db {
		create table User_2
	} or { panic(err) }

	sql db {
		insert users1 into User_2
		insert users2 into User_2
	} or { panic(err) }

	// mut result := sql db {
	// 	select from User
	// } or { panic(err) }
	// dump(result)

	mut qb := orm.new_query[User_2](db)

	qb.set('name = ?', 'admin')!
		.set('nickname = ?', 'nickname_admin1')!
		.where('id = ?', '1')!
		.update()!

	result1 := qb.select('id', 'name', 'nickname')!
		.where('id = ?', '2')!
		.query()!
	// qb.where('id != ?','000')!
	dump(result1)
}
