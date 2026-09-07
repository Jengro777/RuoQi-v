module schema_iam

import time

@[comment: 'IAM Token表']
@[table: 'iam_token']
pub struct IamToken {
pub:
	id         string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	user_id    string @[comment: '用户ID'; index: 'idx_iam_token_user_id'; sql: 'user_id'; sql_type: 'CHAR(36)']
	username   string @[comment: '用户名'; sql_type: 'VARCHAR(255)']
	token      string @[comment: 'Token字符串'; index: 'idx_iam_token_token'; sql_type: 'VARCHAR(1000)']
	source     string @[comment: '来源: sys/本地, 第三方如github'; sql_type: 'VARCHAR(255)']
	expired_at time.Time @[comment: '过期时间'; sql_type: 'TIMESTAMP']
	status     u8 @[comment: '0: 禁用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
