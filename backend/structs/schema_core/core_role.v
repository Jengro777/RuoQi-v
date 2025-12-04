module schema_core

import time

@[unique_key: 'tenant_id,name']
@[comment: '角色表']
@[table: 'core_role']
pub struct CoreRole {
pub:
	id             string  @[comment: '租户角色ID,UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	tenant_id      string  @[comment: '所属租户ID, 默认全局租户ID: 00000000-0000-0000-0000-000000000000'; sql_type: 'CHAR(36)']
	name           string  @[comment: '角色名称'; sql_type: 'VARCHAR(255)']
	default_router string  @[comment: 'Default menu : dashboard | 默认登录页面'; default: '"/dashboard"'; omitempty; sql_type: 'VARCHAR(255)']
	remark         ?string @[comment: 'Remark | 备注'; omitempty; sql_type: 'VARCHAR(255)']
	sort           u32     @[comment: 'Order number | 排序编号'; default: 0; omitempty; sql_type: 'int']
	status         u8      @[comment: '状态，0：正常，1：禁用'; default: 0; omitempty; sql_type: 'tinyint']
	type           string  @[comment: '角色类型: tenant/global'; default: '"tenant"'; sql_type: 'VARCHAR(255)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
