module schema_fms

import time

// 云文件表
@[table: 'fms_cloud_file']
pub struct FmsCloudFile {
pub:
	id                           string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name                         string @[comment: 'The file`s name | 文件名'; index: 'cloudfile_name'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)']
	url                          string @[comment: 'The file`s url | 文件地址'; omitempty; required; sql: 'url'; sql_type: 'VARCHAR(255)']
	size                         u64    @[comment: 'The file`s size | 文件大小'; omitempty; required; sql: 'size'; sql_type: 'bigint unsigned']
	file_type                    u8     @[comment: 'The file`s type | 文件类型'; index: 'cloudfile_file_type'; omitempty; required; sql: 'file_type'; sql_type: 'tinyint unsigned']
	user_id                      string @[comment: 'The user who upload the file | 上传用户的 ID'; omitempty; required; sql: 'user_id'; sql_type: 'VARCHAR(255)']
	cloud_file_storage_providers ?u64   @[comment: 'Reference to storage provider'; omitempty; sql: 'cloud_file_storage_providers'; sql_type: 'bigint unsigned']
	status                       u8     @[comment: 'State true: normal false: ban | 状态 true 正常 false 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
