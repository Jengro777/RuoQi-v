module schema_job

import time

// 系统任务日志表
@[table: 'job_task_log']
pub struct JobTaskLog {
pub:
	id             string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	started_at     time.Time @[comment: 'Task Started Time | 任务启动时间'; omitempty; required; sql: 'started_at'; sql_type: 'TIMESTAMP DEFAULT now()']
	finished_at    time.Time @[comment: 'Task Finished Time | 任务完成时间'; omitempty; required; sql: 'finished_at'; sql_type: 'TIMESTAMP DEFAULT now()']
	result         u8 @[comment: 'The Task Process Result | 任务执行结果'; omitempty; required; sql: 'result'; sql_type: 'smallint']
	task_task_logs ?string @[comment: 'Reference to the parent task'; omitempty; sql: 'task_task_logs'; sql_type: 'CHAR(36)']
	del_flag       i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; omitempty; sql_type: 'smallint']
	created_at     time.Time @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	updated_at     time.Time @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id     ?string @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	updater_id     ?string @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
}
