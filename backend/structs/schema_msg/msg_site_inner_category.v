module schema_msg

import time

// 站内私信消息分类表
@[table: 'msg_site_inner_category']
pub struct MsgSiteInnerCategory {
pub:
	id          string  @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	title       string  @[comment: 'Category Title | 分类名称'; omitempty; required; sql: 'title'; sql_type: 'VARCHAR(255)']
	description ?string @[comment: 'Category Description | 分类描述'; omitempty; sql: 'description'; sql_type: 'VARCHAR(255)']
	remark      ?string @[comment: 'Category Remark | 备注信息'; omitempty; sql: 'remark'; sql_type: 'VARCHAR(255)']
	status      u8      @[comment: 'State true: normal false: ban | 状态 true 正常 false 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
