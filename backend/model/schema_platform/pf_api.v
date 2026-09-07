module schema_platform

import time

@[comment: '平台API注册表']
@[table: 'pf_api']
pub struct PfApi {
pub:
	id           string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	path         string @[comment: 'API 路径'; sql_type: 'VARCHAR(255)']
	description  ?string @[comment: 'API 描述'; sql_type: 'VARCHAR(255)']
	api_group    string @[comment: 'API 分组'; sql_type: 'VARCHAR(255)']
	service_name string @[comment: '服务名称'; sql_type: "VARCHAR(255) DEFAULT 'Other'"]
	method       string @[comment: 'HTTP 方法'; sql_type: "VARCHAR(32) DEFAULT 'POST'"]
	is_required  u8 @[comment: '是否必选: 0否 1是'; default: 0; sql_type: 'smallint']
	status       u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id   ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
