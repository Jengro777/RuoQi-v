module schema_fms

// 文件与标签关联表
@[table: 'fms_file_join_tag']
pub struct FmsFileJoinTag {
pub:
	file_tag_id string @[comment: '标签ID'; primary; sql: 'file_tag_id'; sql_type: 'CHAR(36)']
	file_id     string @[comment: '文件UUID'; primary; sql: 'file_id'; sql_type: 'CHAR(36)']
}
