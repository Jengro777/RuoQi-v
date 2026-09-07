module schema_iam

import time

@[comment: 'IAM 连接器表（OAuth提供商）']
@[table: 'iam_connector']
pub struct IamConnector {
pub:
	id          string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	name        string @[comment: '连接器显示名称'; sql_type: 'VARCHAR(100)']
	logo        string @[comment: '连接器Logo'; sql_type: 'VARCHAR(255)']
	provider    string @[comment: '认证提供商: google/github/wechat'; sql_type: 'VARCHAR(100)']
	type        u8 @[comment: '0邮件短信 1社交连接器'; sql_type: 'smallint']
	config      string @[comment: '连接器配置JSON'; sql_type: 'json']
	description string @[comment: '连接器描述'; sql_type: 'VARCHAR(500)']
	status      u8 @[comment: '0: 禁用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id  string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
