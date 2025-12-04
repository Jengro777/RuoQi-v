module schema_job

import time

// 系统定时任务表
@[table: 'job_task']
pub struct JobTask {
pub:
	id              string @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name            string @[comment: 'Task Name | 任务名称'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)']
	task_group      string @[comment: 'Task Group | 任务分组'; omitempty; required; sql: 'task_group'; sql_type: 'VARCHAR(255)']
	cron_expression string @[comment: 'Cron expression | 定时任务表达式'; omitempty; required; sql: 'cron_expression'; sql_type: 'VARCHAR(255)']
	pattern         string @[comment: 'Cron Pattern | 任务的模式 （用于区分和确定要执行的任务）'; omitempty; required; sql: 'pattern'; sql_type: 'VARCHAR(255)'; unique: 'task_pattern']
	payload         string @[comment: 'The data used in cron (JSON string) | 任务需要的数据(JSON 字符串)'; omitempty; required; sql: 'payload'; sql_type: 'VARCHAR(255)']
	status          u8     @[comment: 'Status 1: normal 2: ban | 状态 1 正常 2 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint unsigned']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
