module schema_fms

import time

// 云文件标签表
@[table: 'fms_cloud_file_tag']
pub struct FmsCloudFileTag {
pub:
	id     string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name   string @[comment: 'CloudFileTag`s name | 标签名称'; index: 'cloudfiletag_name'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)']
	remark ?string @[comment: 'The remark of tag | 标签的备注'; omitempty; sql: 'remark'; sql_type: 'VARCHAR(255)']
	status u8 @[comment: 'Status 0: ban 1: normal | 状态 0 禁用 1 正常'; default: 1; omitempty; sql: 'status'; sql_type: 'smallint']

	updater_id ?string @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; omitempty; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
