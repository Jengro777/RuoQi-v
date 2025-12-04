module schema_fms

import time

// 文件管理系统文件表
@[table: 'fms_file']
pub struct FmsFile {
pub:
	id        string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name      string @[comment: 'File`s name | 文件名称'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)']
	file_type u8     @[comment: 'File`s type | 文件类型'; index: 'file_file_type'; omitempty; required; sql: 'file_type'; sql_type: 'tinyint unsigned']
	size      u64    @[comment: 'File`s size | 文件大小'; omitempty; required; sql: 'size'; sql_type: 'bigint unsigned']
	path      string @[comment: 'File`s path | 文件路径'; omitempty; required; sql: 'path'; sql_type: 'VARCHAR(255)']
	user_id   string @[comment: 'User`s UUID | 用户的 UUID'; index: 'file_user_id'; omitempty; required; sql: 'user_id'; sql_type: 'VARCHAR(255)']
	md5       string @[comment: 'The md5 of the file | 文件的 md5'; omitempty; required; sql: 'md5'; sql_type: 'VARCHAR(255)']
	status    u8     @[comment: 'Status 1: normal 2: ban | 状态 1 正常 2 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint unsigned']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
