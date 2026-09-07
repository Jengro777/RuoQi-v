module schema_workspace

import time

@[comment: '工作区表']
@[table: 'ws_workspace']
pub struct WsWorkspace {
pub:
	id          string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	tenant_id   string @[comment: '所属租户ID'; index: 'idx_ws_workspace_tenant'; sql_type: 'CHAR(36)']
	name        string @[comment: '工作区名称'; sql_type: 'VARCHAR(255)']
	description string @[comment: '描述'; sql_type: 'VARCHAR(255)']
	status      u8 @[comment: '0: 禁用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id  string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
