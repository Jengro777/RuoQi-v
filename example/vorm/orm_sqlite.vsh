#!/usr/bin/env -S v run

import db.sqlite
import time

@[table: 'sys_users']
struct User {
pub:
	id         string     @[primary; sql_type: 'VARCHAR(255)'; unique]
	name       ?string    @[sql_type: 'VARCHAR(255)']
	nickname   ?string    @[sql_type: 'VARCHAR(255)']
	mobile     ?string    @[sql_type: 'VARCHAR(255)']
	email      ?string    @[sql_type: 'VARCHAR(255)']
	created_at time.Time  @[omitempty; sql_type: 'TIMESTAMP']
	updated_at ?time.Time @[default: new; omitempty; sql_type: 'TIMESTAMP']
}

// 查询用户数据
fn query_users(mut db sqlite.DB) ![]User {
	users := sql db {
		select from User
	}!
	return users
}

// 根据条件查询用户
fn find_user_by_id(mut db sqlite.DB) ![]User {
	user := sql db {
		select from User where id == '1'
	}!
	return user
}

fn main() {
	// 初始化数据库
	mut db := init_database()!
	defer { db.close() or {} }
	// 插入数据
	insert_users(mut db) or { panic(err) }

	req := UserReq{
		name:     'Jengro'
		nickname: 'Woo'
		mobile:   '535770088'
		email:    'admin@admin.com'
	}
	// 更改用户数据
	update_users(mut db, req) or { panic(err) }

	// 查询所有用户
	users := query_users(mut db) or { panic(err) }
	dump(users)
	// // 根据ID查询特定用户
	// user := find_user_by_id(mut db) or { panic(err) }
	// dump(user)
}

// 初始化数据库和表结构
fn init_database() !&sqlite.DB {
	mut db := sqlite.connect(':memory:')!

	sql db {
		create table User
	}!

	return &db
}

// 插入用户数据
fn insert_users(mut db sqlite.DB) ! {
	users1 := User{
		id:         '1'
		name:       'Jengro'
		nickname:   'Woo'
		mobile:     '535770088'
		email:      'admin@admin.com'
		created_at: time.now()
		updated_at: time.now()
	}

	users2 := User{
		id:         '2'
		name:       'Dev'
		nickname:   'T'
		mobile:     '15020579521'
		email:      'dev@dev.com'
		created_at: time.now()
		updated_at: time.now()
	}

	sql db {
		insert users1 into User
		insert users2 into User
	}!
}

struct UserReq {
	name     ?string @[json: 'name']
	nickname ?string @[json: 'nickname']
	mobile   ?string @[json: 'mobile']
	email    ?string @[json: 'email']
}

// 插入用户数据
fn update_users(mut db sqlite.DB, req UserReq) ! {
	name_dyn := 'Jengro888'

	sql db {
		update User set
			email = fn [req] () string {
				return if req.email != '' { 'nickname_1' } else { 'nickname_0' }
			}(),
			name = name_dyn
		where id == '1'
	}!
}

// // 插入用户数据
// fn update_users(mut db sqlite.DB) ! {
// 	user1 := User{
// 		name:     'Jengro888'
// 		nickname: 'Woo888'
// 		mobile:   '535770088-888'
// 		email:    'admin@admin.com888'
// 	}

// 	sql db {
// 		update User set user1 where id == '1'
// 	}!
// }
