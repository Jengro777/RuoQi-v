module schema_workspace

import time

@[comment: '工作区部门表']
@[table: 'ws_department']
pub struct WsDepartment {
pub:
	id           string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	parent_id    string @[comment: '父部门ID，0为根'; default: '`0`'; index: 'idx_ws_dept_parent'; sql_type: 'CHAR(36)']
	name         string @[comment: '部门名称'; sql_type: 'VARCHAR(255)']
	code         string @[comment: '部门编码'; sql_type: 'VARCHAR(64)']
	description  string @[comment: '描述'; sql_type: 'VARCHAR(500)']
	sort         u32 @[comment: '排序'; default: 0; sql_type: 'integer']
	status       u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id   ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
