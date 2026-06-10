module schema_iam

import time

@[comment: 'IAM 角色表']
@[table: 'iam_role']
pub struct IamRole {
pub:
	id         string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	name       string     @[comment: '角色名称'; sql_type: 'VARCHAR(255)']
	code       string     @[comment: '角色码，前端权限控制'; sql_type: 'VARCHAR(255)']
	remark     string     @[comment: '备注'; sql_type: 'VARCHAR(255)']
	sort       u32        @[comment: '排序编号'; default: 0; sql_type: 'int']
	status     u8         @[comment: '0正常 1禁用'; default: 0; sql_type: 'tinyint']
	updater_id string     @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id string     @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
