module schema_workspace

@[unique_key: 'workspace_id,role_id,api_id,source_type,source_id']
@[comment: '工作区角色API关联表（按应用隔离）']
@[table: 'ws_role_api']
pub struct WsRoleApi {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	role_id      string @[comment: '角色ID'; sql_type: 'CHAR(36)']
	api_id       string @[comment: 'API ID'; sql_type: 'CHAR(36)']
	source_type  string @[comment: '应用来源: wms/tms/mall'; sql_type: 'VARCHAR(32)']
	source_id    string @[comment: '应用实例ID'; sql_type: 'CHAR(36)']
}
