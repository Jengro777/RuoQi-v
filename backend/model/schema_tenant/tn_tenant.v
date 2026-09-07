module schema_tenant

import time

@[comment: '租户表（组织/团队）']
@[table: 'tn_tenant']
pub struct TnTenant {
pub:
	id         string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	owner_id   string @[comment: '所有者用户ID'; sql_type: 'CHAR(36)']
	logo_url   string @[comment: '租户Logo地址'; sql_type: 'VARCHAR(500)']
	name       string @[comment: '租户名称'; sql_type: "VARCHAR(100) DEFAULT '我的团队'"]
	type       u8 @[comment: '0个人空间 1团队空间'; default: 0; sql_type: 'smallint']
	slug       string @[comment: '用于URL标识'; sql_type: 'VARCHAR(100)']
	status     u8 @[comment: '0待审核 1活跃 2暂停'; default: 0; sql_type: 'smallint']
	updater_id ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
