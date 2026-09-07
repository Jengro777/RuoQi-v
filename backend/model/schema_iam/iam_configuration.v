module schema_iam

import time

@[comment: 'IAM 配置表（连接器开关、OAuth参数等）']
@[table: 'iam_configuration']
pub struct IamConfiguration {
pub:
	id         string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name       string @[comment: '配置名称'; sql_type: 'VARCHAR(255)']
	key        string @[comment: '配置键名'; sql_type: 'VARCHAR(255)']
	value      string @[comment: '配置值'; sql_type: 'VARCHAR(255)']
	category   string @[comment: '配置分类'; sql_type: 'VARCHAR(255)']
	remark     ?string @[comment: '备注'; sql_type: 'VARCHAR(255)']
	sort       u32 @[comment: '排序编号'; default: 0; sql_type: 'integer']
	status     u8 @[comment: '0: 禁用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
