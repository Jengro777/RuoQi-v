module api

import veb
import dbpool

pub struct Context {
	veb.Context
pub mut:
	dbpool &dbpool.DatabasePool
}

@[table: 'sys_users']
@[comment: ' user']
pub struct SysUser {
	id       string @[immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	username string @[omitempty; required; sql: 'username'; sql_type: 'VARCHAR(255)'; unique: 'username']
	password string @[omitempty; required; sql: 'password'; sql_type: 'VARCHAR(255)']
	status   u8     @[default: 0; omitempty; sql_type: 'tinyint']
}
