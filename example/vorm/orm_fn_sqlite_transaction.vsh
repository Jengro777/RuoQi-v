#!/usr/bin/env -S v run

import db.sqlite
import time
import orm

@[table: 'sys_users']
struct User1 {
pub:
	id         string     @[immutable; primary; sql: 'id'; sql_type: 'VARCHAR(255)'; unique]
	name       ?string    @[immutable; sql: 'names'; sql_type: 'VARCHAR(255)'; unique]
	created_at time.Time  @[omitempty; sql_type: 'TIMESTAMP']
	updated_at ?time.Time @[default: new; omitempty; sql_type: 'TIMESTAMP']
}

fn main() {
	mut db := sqlite.connect(':memory:')!
	defer { db.close() or {} }

	user1 := User1{
		id: '001'
		// name:       'Jengro'
		created_at: time.now()
		updated_at: time.now()
	}

	user2 := User1{
		id:         '002'
		name:       'Dev'
		created_at: time.now()
		updated_at: time.now()
	}

	sql db {
		create table User1
	} or { panic(err) }

	mut qb := orm.new_query[User1](db)

	db.begin()!
	qb.insert(user1)!
	qb.insert(user2)!
	db.commit()!

	result1 := qb.select('id', 'names')!
		.query()!
	// qb.where('id != ?','001')!
	dump(result1)
}
