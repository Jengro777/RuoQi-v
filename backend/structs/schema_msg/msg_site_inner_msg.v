module schema_msg

import time

// 站内私信消息表
@[table: 'msg_site_inner_msg']
pub struct MsgSiteInnerMsg {
pub:
	id                            string  @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	avatar                        ?string @[comment: 'Avatar | 头像或图标'; omitempty; sql: 'avatar'; sql_type: 'VARCHAR(255)']
	title                         string  @[comment: 'Message Title | 消息标题'; omitempty; required; sql: 'title'; sql_type: 'VARCHAR(255)']
	content                       string  @[comment: 'Message Content | 消息内容'; omitempty; required; sql: 'content'; sql_type: 'VARCHAR(255)']
	sender                        string  @[comment: 'Message Sender | 消息发送者'; immutable; omitempty; sql: 'sender'; sql_type: 'CHAR(36)']
	receiver                      string  @[comment: 'Message Receiver | 消息接收者'; immutable; omitempty; sql: 'receiver'; sql_type: 'CHAR(36)']
	is_read                       u8      @[comment: 'Read symbol | 已读状态'; omitempty; required; sql: 'is_read'; sql_type: 'tinyint(1)']
	inner_msg_category_inner_msgs ?u64    @[comment: 'Message category reference'; omitempty; sql: 'inner_msg_category_inner_msgs'; sql_type: 'bigint unsigned']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
