module schema_fms

// 云文件与标签关联表
@[table: 'fms_cloudfile_join_cloudtag']
pub struct FmsCloudFileCloudFileTag {
pub:
	cloud_file_tag_id string @[comment: '云文件标签ID'; primary; sql: 'cloud_file_tag_id'; sql_type: 'CHAR(36)']
	cloud_file_id     string @[comment: '云文件UUID'; primary; sql: 'cloud_file_id'; sql_type: 'CHAR(36)']
}
