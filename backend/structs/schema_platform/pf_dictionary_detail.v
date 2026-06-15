module schema_platform

import time

@[comment: '平台字典明细表']
@[table: 'pf_dictionary_detail']
pub struct PfDictionaryDetail {
pub:
	id            string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	dictionary_id string     @[comment: '字典ID'; sql_type: 'CHAR(36)']
	label         string     @[comment: '显示标签'; sql_type: 'VARCHAR(255)']
	value         string     @[comment: '值'; sql_type: 'VARCHAR(255)']
	sort          u32        @[comment: '排序'; default: 0; sql_type: 'int']
	status        u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id    ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at    time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id    ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at    time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag      u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at    ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
