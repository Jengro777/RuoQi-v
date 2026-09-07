module schema_platform

import time

@[comment: '平台字典表']
@[table: 'pf_dictionary']
pub struct PfDictionary {
pub:
	id          string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	name        string @[comment: '字典名称'; sql_type: 'VARCHAR(255)']
	code        string @[comment: '字典编码'; index: 'idx_pf_dict_code'; sql_type: 'VARCHAR(64)']
	description string @[comment: '描述'; sql_type: 'VARCHAR(500)']
	status      u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id  ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
