module schema_msg

import time

// 短信服务提供商表
@[table: 'msg_sms_provider']
pub struct MsgSmsProvider {
pub:
	id         string @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name       string @[comment: 'The SMS provider name | 短信服务的提供商'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)'; unique: 'name']
	secret_id  string @[comment: 'The secret ID | 密钥 ID'; omitempty; required; sql: 'secret_id'; sql_type: 'VARCHAR(255)']
	secret_key string @[comment: 'The secret key | 密钥 Key'; omitempty; required; sql: 'secret_key'; sql_type: 'VARCHAR(255)']
	region     string @[comment: 'The service region | 服务器所在地区'; omitempty; required; sql: 'region'; sql_type: 'VARCHAR(255)']
	is_default u8     @[comment: 'Is it the default provider | 是否为默认提供商'; default: 0; omitempty; sql: 'is_default'; sql_type: 'tinyint(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
