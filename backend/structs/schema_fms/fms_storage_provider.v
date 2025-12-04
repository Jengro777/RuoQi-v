module schema_fms

import time

// 文件存储服务提供商表
@[table: 'fms_storage_provider']
pub struct FmsStorageProvider {
pub:
	id         string  @[comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name       string  @[comment: 'The cloud storage service name | 服务名称'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)'; unique: 'name']
	bucket     string  @[comment: 'The cloud storage bucket name | 云存储服务的存储桶'; omitempty; required; sql: 'bucket'; sql_type: 'VARCHAR(255)']
	secret_id  string  @[comment: 'The secret ID | 密钥 ID'; omitempty; required; sql: 'secret_id'; sql_type: 'VARCHAR(255)']
	secret_key string  @[comment: 'The secret key | 密钥 Key'; omitempty; required; sql: 'secret_key'; sql_type: 'VARCHAR(255)']
	endpoint   string  @[comment: 'The service URL | 服务器地址'; omitempty; required; sql: 'endpoint'; sql_type: 'VARCHAR(255)']
	folder     ?string @[comment: 'The folder in cloud | 云服务目标文件夹'; omitempty; sql: 'folder'; sql_type: 'VARCHAR(255)']
	region     string  @[comment: 'The service region | 服务器所在地区'; omitempty; required; sql: 'region'; sql_type: 'VARCHAR(255)']
	is_default u8      @[comment: 'Is it the default provider | 是否为默认提供商'; default: 0; omitempty; sql: 'is_default'; sql_type: 'tinyint(1)']
	use_cdn    u8      @[comment: 'Does it use CDN | 是否使用 CDN'; default: 0; omitempty; sql: 'use_cdn'; sql_type: 'tinyint(1)']
	cdn_url    ?string @[comment: 'CDN URL | CDN 地址'; omitempty; sql: 'cdn_url'; sql_type: 'VARCHAR(255)']
	status     u8      @[comment: 'State true: normal false: ban | 状态 true 正常 false 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
