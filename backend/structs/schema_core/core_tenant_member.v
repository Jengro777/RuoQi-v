module schema_core

import time

@[comment: '租户成员表,member_id==user_id']
@[unique_key: 'tenant_id,member_id']
@[index: 'tenant_id,member_id']
@[table: 'core_tenant_member']
pub struct CoreTenantMember {
pub:
	tenant_id string @[comment: 'Tenant ID | 租户ID'; immutable; sql: 'tenant_id'; sql_type: 'CHAR(36)']
	member_id string @[comment: 'User ID | 用户ID'; immutable; sql: 'member_id'; sql_type: 'CHAR(36)']

	is_owner u8 @[comment: '是否是租户所有者,0:否,1:是'; immutable; sql: 'is_owner'; sql_type: 'TINYINT(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
