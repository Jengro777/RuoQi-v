module schema_core

import time

@[comment: '项目表: 全局项目聚合全局应用; 项目(Project) 或 系统 (System) 或 平台 (Platform)']
@[table: 'core_project']
pub struct CoreProject {
pub:
	id           string @[comment: '项目ID,UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	name         string @[comment: '项目名称'; primary; required; sql_type: 'VARCHAR(100)'; unique]
	display_name string @[comment: '显示项目名称'; omitempty; sql_type: 'VARCHAR(100)']
	logo         string @[comment: '项目Logo'; omitempty; sql_type: 'VARCHAR(100)']
	description  string @[comment: '项目描述'; omitempty; sql_type: 'VARCHAR(100)']

	updater_id ?string    @[comment: 'sys 修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: 'sys 创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
