module schema_workspace

@[comment: '工作区角色菜单关联表（按应用隔离）']
@[unique_key: 'workspace_id,role_id,menu_id,source_type,source_id']
@[table: 'ws_role_menu']
pub struct WsRoleMenu {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	role_id      string @[comment: '角色ID'; sql_type: 'CHAR(36)']
	menu_id      string @[comment: '菜单ID'; sql_type: 'CHAR(36)']
	source_type  string @[comment: '应用来源: wms/tms/mall'; sql_type: 'VARCHAR(32)']
	source_id    string @[comment: '应用实例ID'; sql_type: 'CHAR(36)']
}
