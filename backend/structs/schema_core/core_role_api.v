module schema_core

@[unique_key: 'role_id, api_id, source_type, source_id']
@[index: 'role_id, api_id, source_type, source_id']
@[comment: '租户角色与api资源关系表']
@[table: 'core_role_api']
pub struct CoreRoleApi {
pub:
	role_id string @[comment: '角色ID'; sql_type: 'CHAR(36)']
	api_id  string @[comment: 'API ID'; sql_type: 'CHAR(36)']
	// 来源级别,表示这个资源属于哪个来源（例如哪个租户、哪个订阅的子应用）租户订阅应用表
	source_type string @[comment: '来源类型: tenant/subapp'; sql_type: 'VARCHAR(32)']
	source_id   string @[comment: '来源ID: subapp_id(tenant)'; sql_type: 'CHAR(36)']
}
