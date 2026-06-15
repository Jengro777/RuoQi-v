module schema_workspace

import time

@[comment: '工作区岗位表']
@[table: 'ws_position']
pub struct WsPosition {
pub:
	id           string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	workspace_id string     @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	name         string     @[comment: '岗位名称'; sql_type: 'VARCHAR(255)']
	code         string     @[comment: '岗位编码'; sql_type: 'VARCHAR(64)']
	description  string     @[comment: '描述'; sql_type: 'VARCHAR(500)']
	sort         u32        @[comment: '排序'; default: 0; sql_type: 'int']
	status       u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id   ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
