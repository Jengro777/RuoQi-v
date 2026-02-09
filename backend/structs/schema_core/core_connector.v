module schema_core

import time

// Github  Google QQ WeChat Facebook DingTalk Weibo Gitee LinkedIn Wecom Lark Gitlab Apple AzureAD Slack

@[comment: '连接器表/Oauth提供商表']
@[table: 'core_connector']
pub struct CoreConnector {
pub:
	id          string @[comment: '连接器ID, UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	name        string @[comment: '连接器显示名称'; required; sql_type: 'VARCHAR(100)']
	logo        string @[comment: '连接器Logo'; omitempty; sql_type: 'VARCHAR(255)']
	provider    string @[comment: '连接器标识,认证提供商: google, github, wechat'; required; sql_type: 'VARCHAR(100)']
	type        u8     @[comment: '类型: 0 Email and SMS, 1 Social connectors'; required; sql_type: 'tinyint(1)']
	config      string @[comment: '连接器配置:json格式'; required; sql_type: 'json']
	description string @[comment: '连接器描述'; omitempty; sql_type: 'VARCHAR(500)']
	status      u8     @[comment: '连接器状态, 0:active, 1:inactive'; default: 0; sql_type: 'tinyint(20)']

	updater_id ?string    @[comment: 'sys 修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: 'sys 创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
