module schema_tenant

import time

// unique_key 说明：同一租户对同一产品的同一配置项只能有一条记录，防止重复；
// 更新配置值通过 UPDATE value 实现，不受此约束影响。
@[comment: '租户产品配置表——租户对已订阅产品的自定义配置']
@[unique_key: 'tenant_id,product_id,key']
@[table: 'tn_config']
pub struct TnConfig {
pub:
	id          string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	tenant_id   string @[comment: '租户ID'; immutable; sql_type: 'CHAR(36)']
	product_id  string @[comment: '产品ID'; immutable; sql_type: 'CHAR(36)']
	key         string @[comment: '配置键'; sql_type: 'VARCHAR(128)']
	value       string @[comment: '配置值'; sql_type: 'TEXT']
	category    string @[comment: '分类'; sql_type: 'VARCHAR(64)']
	description string @[comment: '描述'; sql_type: 'VARCHAR(500)']
	status      u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id  ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
