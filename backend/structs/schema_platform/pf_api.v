module schema_platform

import time

@[comment: '平台API注册表']
@[table: 'pf_api']
pub struct PfApi {
pub:
	id           string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	path         string     @[comment: 'API 路径'; sql_type: 'VARCHAR(255)']
	description  ?string    @[comment: 'API 描述'; sql_type: 'VARCHAR(255)']
	api_group    string     @[comment: 'API 分组'; sql_type: 'VARCHAR(255)']
	service_name string     @[comment: '服务名称'; default: '"Other"'; sql_type: 'VARCHAR(255)']
	method       string     @[comment: 'HTTP 方法'; default: '"POST"'; sql_type: 'VARCHAR(32)']
	is_required  u8         @[comment: '是否必选: 0否 1是'; default: 0; sql_type: 'tinyint(1)']
	status       u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id   ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
