module schema_iam

import time

@[comment: 'IAM 用户表']
@[table: 'iam_user']
pub struct IamUser {
pub:
	id          string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	username    string @[comment: '登录名'; sql_type: 'VARCHAR(255)'; unique: 'username']
	password    string @[comment: '密码'; sql_type: 'VARCHAR(255)']
	nickname    string @[comment: '昵称'; sql_type: 'VARCHAR(255)']
	description string @[comment: '用户描述'; sql_type: 'VARCHAR(255)']
	home_path   string @[comment: '登录后首页路径'; sql_type: "VARCHAR(255) DEFAULT '/dashboard'"]
	mobile      string @[comment: '手机号'; sql_type: 'VARCHAR(255)']
	email       string @[comment: '邮箱'; sql_type: 'VARCHAR(255)']
	avatar      string @[comment: '头像路径'; sql_type: 'VARCHAR(512)']
	status      u8 @[comment: '0: 禁用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id  string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
