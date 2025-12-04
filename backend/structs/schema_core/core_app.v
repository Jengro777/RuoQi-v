module schema_core

import time

@[comment: '应用表:全局应用供租户订阅; 应用 (Application) 或 子系统 (Subsystem) 或 业务域 (Business Domain)']
@[table: 'core_application']
pub struct CoreApp {
pub:
	id                    string @[comment: '应用UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	project_id            string @[comment: '所属项目UUID'; primary; required; sql_type: 'CHAR(36)']
	name                  string @[comment: '应用名称'; primary; required; sql_type: 'VARCHAR(100)'; unique]
	logo                  string @[comment: '应用Logo'; omitempty; sql_type: 'VARCHAR(255)']
	homepage_path         string @[comment: '应用主页Path'; omitempty; sql_type: 'VARCHAR(500)']
	description           string @[comment: '应用描述'; omitempty; sql_type: 'VARCHAR(500)']
	is_multi_tenant       u8     @[comment: '是否多租户应用：0-否，1-是'; default: 0; sql_type: 'tinyint(1)']
	max_subscribers       u16    @[comment: '最大可订阅租户数，0表示无限制'; default: 0; sql_type: 'smallint']
	max_tenant_subscribes u8     @[comment: '单个租户最大订阅次数，0表示无限制'; default: 1; sql_type: 'tinyint']
	subscribe_mode        u8     @[comment: '订阅模式：0-不可订阅，1-自由订阅，2-需审批'; default: 1; sql_type: 'tinyint']
	status                u8     @[comment: '应用状态, 0:inactive, 1:active'; default: 1; sql_type: 'tinyint(20)']

	updater_id ?string    @[comment: 'sys 修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: 'sys 创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
