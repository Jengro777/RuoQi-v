module schema_core

import time

@[comment: '应用客户端表; 客户端 (Client) 或 终端 (Terminal) 或 前端 (Frontend)']
@[table: 'core_app_client']
pub struct CoreAppClient {
pub:
	id             string @[comment: 'UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	project_id     string @[comment: 'Project ID | 项目ID'; immutable; sql: 'project_id'; sql_type: 'CHAR(36)']
	application_id string @[comment: 'Application ID | 应用ID'; immutable; primary; sql: 'application_id'; sql_type: 'CHAR(36)']
	name           string @[comment: 'Name | 名称'; immutable; sql: 'name'; sql_type: 'VARCHAR(255)']
	client_type    u8     @[comment: '客户端类型：0-未知，1-WEB，2-H5，3-Android，4-iOS，5-鸿蒙，6-微信小程序'; default: 0; sql_type: 'tinyint']
	secret         string @[comment: '客户端密钥（加密存储）'; sql_type: 'VARCHAR(255)']
	redirect_url   string @[comment: '回调地址，多个用逗号分隔'; sql_type: 'VARCHAR(255)']
	status         u8     @[comment: '客户端状态：0-停用，1-激活'; default: 1; sql_type: 'tinyint(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
