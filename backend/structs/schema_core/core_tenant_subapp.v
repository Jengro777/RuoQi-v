module schema_core

import time

@[comment: '租户订阅应用表 | core_tenant_subscribe-application']
@[table: 'core_tenant_subapp']
pub struct CoreTenantSubApp {
pub:
	id             string @[comment: '应用订阅ID, UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	tenant_id      string @[comment: 'Tenant ID | 租户ID'; immutable; sql: 'tenant_id'; sql_type: 'CHAR(36)']
	application_id string @[comment: 'Application ID | 订阅的应用ID'; immutable; sql_type: 'CHAR(36)']
	status         u8     @[comment: '应用订阅状态; 0 未订阅，1 已订阅，2 已取消，3 已过期'; immutable; sql_type: 'tinyint(20)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
