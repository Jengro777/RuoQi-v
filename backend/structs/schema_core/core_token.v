module schema_core

import time

@[table: 'core_token']
@[comment: 'Token表']
@[index: 'token']
pub struct CoreToken {
pub:
	id         string    @[comment: 'UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	user_id    string    @[comment: 'User`s UUID | 用户的UUID'; omitempty; sql: 'user_id'; sql_type: 'CHAR(36)']
	username   string    @[comment: 'Username | 用户名'; default: '"unknown"'; omitempty; sql_type: 'VARCHAR(255)']
	token      string    @[comment: 'Token string | Token 字符串'; omitempty; sql_type: 'VARCHAR(1000)']
	source     string    @[comment: 'Log in source such as GitHub | Token 来源 （本地为core, 第三方如github等）'; omitempty; sql_type: 'VARCHAR(255)']
	expired_at time.Time @[comment: 'Expire time | 过期时间'; omitempty; sql_type: 'TIMESTAMP']
	status     u8        @[comment: '状态，0：正常，1：禁用'; default: 0; omitempty; sql_type: 'tinyint(20)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
