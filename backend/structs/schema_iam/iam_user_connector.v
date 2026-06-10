module schema_iam

import time

@[comment: 'IAM 用户连接器关联表']
@[table: 'iam_user_connector']
pub struct IamUserConnector {
pub:
	id               string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	user_id          string     @[comment: '用户ID'; sql_type: 'CHAR(36)']
	connector_id     string     @[comment: '连接器ID'; sql_type: 'CHAR(36)']
	provider_user_id string     @[comment: '第三方系统中的用户ID'; sql_type: 'CHAR(36)']
	profile          string     @[comment: '用户资料快照JSON'; sql_type: 'json']
	updater_id       string     @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at       time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id       string     @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at       time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag         u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at       ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
