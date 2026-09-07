module schema_base

import time

@[table: 'base_language']
@[comment: '语言表']
pub struct BaseLanguage {
pub:
	id                       string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	language_self_proclaimed string @[comment: '语言自称'; required; sql_type: 'VARCHAR(255)']
	language_code            string @[comment: '语言代码'; index: 'idx_language_code'; required; sql_type: 'VARCHAR(255)']
	two_letter_code          string @[comment: '两字母代码'; required; sql_type: 'VARCHAR(255)']
	three_letter_code        string @[comment: '三字母代码'; required; sql_type: 'VARCHAR(255)']
	utf8_encoding            string @[comment: 'UTF8编码区域'; required; sql_type: 'VARCHAR(255)']
	sort                     ?int @[comment: 'Sort Number | 排序编号'; sql_type: 'integer']
	status                   u8 @[comment: 'Status 0: inactive 1: active | 状态 0 无效 1 有效'; default: 1; sql_type: 'smallint']
	is_basic                 u8 @[comment: '是否基础语言 0:否 1:是'; default: 0; sql_type: 'smallint']

	updater_id ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: 'Update Time | 修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: 'Create Time | 创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; sql_type: 'TIMESTAMP']
}
