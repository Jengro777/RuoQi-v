module schema_core

import time

@[comment: '租户表: 租户/组织/团队']
@[table: 'core_tenant']
pub struct CoreTenant {
pub:
	id       string @[comment: '租户id  UUID rand.uuid_v7()'; immutable; primary; required; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	logo_url string @[comment: '租户logo地址'; sql_type: 'VARCHAR(500)']
	name     string @[comment: '租户名称'; default: '"我的团队"'; omitempty; required; sql_type: 'VARCHAR(100)']
	type     u8     @[comment: '租户类型, 0:个人空间, 1:团队空间'; default: 0; required; sql_type: 'VARCHAR(20)']
	slug     string @[comment: '用于URL标识'; required; sql_type: 'VARCHAR(100)']
	status   u8     @[comment: '租户状态, 0:pending, 1:active, 2:suspended'; default: 0; sql_type: 'tinyint(20)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0:未删除，1:已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
