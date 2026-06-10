module schema_workspace

@[unique_key: 'workspace_id,user_id']
@[comment: '工作区成员表']
@[table: 'ws_member']
pub struct WsMember {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	user_id      string @[comment: '用户ID'; sql_type: 'CHAR(36)']
	role_id      string @[comment: '角色ID'; sql_type: 'CHAR(36)']
}
