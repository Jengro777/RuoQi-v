module schema_msg

import time

// 站内消息通知表
@[table: 'msg_site_notification']
pub struct MsgSiteNotification {
pub:
	id      string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	avatar  ?string @[comment: 'Avatar | 头像或图标'; omitempty; sql: 'avatar'; sql_type: 'VARCHAR(255)']
	title   string @[comment: 'Notification Title | 公告标题'; omitempty; required; sql: 'title'; sql_type: 'VARCHAR(255)']
	content string @[comment: 'Notification Content | 公告内容'; omitempty; required; sql: 'content'; sql_type: 'VARCHAR(255)']
	creator string @[comment: 'Creator | 创建者'; immutable; omitempty; sql: 'creator'; sql_type: 'CHAR(36)']
	status  u8 @[comment: 'State 0: ban 1: normal | 状态 0 禁用 1 正常'; default: 1; omitempty; sql: 'status'; sql_type: 'smallint']

	updater_id ?string @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; omitempty; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
