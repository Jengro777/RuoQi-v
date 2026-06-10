module schema_tenant

import time

@[comment: '租户表（组织/团队）']
@[table: 'tn_tenant']
pub struct TnTenant {
pub:
	id         string     @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	owner_id   string     @[comment: '所有者用户ID'; sql_type: 'CHAR(36)']
	logo_url   string     @[comment: '租户Logo地址'; sql_type: 'VARCHAR(500)']
	name       string     @[comment: '租户名称'; default: '"我的团队"'; sql_type: 'VARCHAR(100)']
	type       u8         @[comment: '0个人空间 1团队空间'; default: 0; sql_type: 'tinyint']
	slug       string     @[comment: '用于URL标识'; sql_type: 'VARCHAR(100)']
	status     u8         @[comment: '0待审核 1活跃 2暂停'; default: 0; sql_type: 'tinyint(20)']
	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
