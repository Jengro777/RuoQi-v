module schema_iam

import time

@[comment: 'IAM 连接器表（OAuth提供商）']
@[table: 'iam_connector']
pub struct IamConnector {
pub:
	id          string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	name        string     @[comment: '连接器显示名称'; sql_type: 'VARCHAR(100)']
	logo        string     @[comment: '连接器Logo'; sql_type: 'VARCHAR(255)']
	provider    string     @[comment: '认证提供商: google/github/wechat'; sql_type: 'VARCHAR(100)']
	type        u8         @[comment: '0邮件短信 1社交连接器'; sql_type: 'tinyint(1)']
	config      string     @[comment: '连接器配置JSON'; sql_type: 'json']
	description string     @[comment: '连接器描述'; sql_type: 'VARCHAR(500)']
	status      u8         @[comment: '0正常 1禁用'; default: 0; sql_type: 'tinyint(20)']
	updater_id  string     @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  string     @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
