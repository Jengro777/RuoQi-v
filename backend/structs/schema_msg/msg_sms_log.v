module schema_msg

import time

// 短信发送日志表
@[table: 'msg_sms_log']
pub struct MsgSmsLog {
pub:
	id           string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	phone_number string @[comment: 'The target phone number | 目标电话'; omitempty; required; sql: 'phone_number'; sql_type: 'VARCHAR(255)']
	content      string @[comment: 'The content | 发送的内容'; omitempty; required; sql: 'content'; sql_type: 'VARCHAR(255)']
	send_status  u8     @[comment: 'The send status, 0 unknown 1 success 2 failed | 发送的状态, 0 未知， 1 成功， 2 失败'; omitempty; required; sql: 'send_status'; sql_type: 'tinyint unsigned']
	provider     string @[comment: 'The sms service provider | 短信服务提供商'; omitempty; required; sql: 'provider'; sql_type: 'VARCHAR(255)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
