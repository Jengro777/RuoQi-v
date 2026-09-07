module schema_workspace

import time

// unique_key 说明：同一 workspace 下同一用户只能有一条成员记录。
@[unique_key: 'workspace_id,user_id']
@[comment: '工作区成员表']
@[table: 'ws_member']
pub struct WsMember {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	user_id      string @[comment: '用户ID'; sql_type: 'CHAR(36)']
	joined_at    time.Time @[comment: '加入日期'; sql_type: 'TIMESTAMP']
	status       u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id   ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
