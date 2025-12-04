module schema_core

@[comment: '租户成员角色关联表']
@[unique_key: 'tenant_id,member_id,role_id']
@[table: 'core_role_tenant_member']
@[index: 'tenant_id, member_id']
pub struct CoreRoleTenantMember {
pub:
	tenant_id string @[comment: '所属租户ID'; sql_type: 'CHAR(36)']
	member_id string @[comment: '租户成员ID'; sql_type: 'CHAR(36)']
	role_id   string @[comment: '租户角色ID'; sql_type: 'CHAR(36)']
}
