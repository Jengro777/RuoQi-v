module schema_core

import time

@[table: 'core_user_connector']
@[comment: '用户连接器表']
pub struct CoreUserConnector {
pub:
	id               string @[comment: '连接器ID, UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	user_id          string @[comment: '用户ID'; immutable; sql: 'user_id'; sql_type: 'CHAR(36)']
	connector_id     string @[comment: '连接器ID'; immutable; sql: 'connector_id'; sql_type: 'CHAR(36)']
	provider_user_id string @[comment: ' 第三方系统中的用户ID'; immutable; sql: 'provider_user_id'; sql_type: 'CHAR(36)']
	profile          string @[comment: '存储用户资料快照（用户名、头像等）'; immutable; sql: 'profile'; sql_type: 'json']

	updater_id ?string    @[comment: 'sys 修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: 'sys 创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
