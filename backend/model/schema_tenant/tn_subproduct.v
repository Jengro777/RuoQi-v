module schema_tenant

import time

// unique_key 说明：同一租户对同一产品只能有一条订阅记录，防止重复 INSERT；
// 套餐变更通过 UPDATE plan_id 实现，不受此约束影响。

@[comment: '租户产品订阅表（含套餐）— subproduct = subscription to a product']
@[unique_key: 'tenant_id,product_id']
@[table: 'tn_subproduct']
pub struct TnSubProduct {
pub:
	id         string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	tenant_id  string @[comment: '租户ID'; immutable; sql: 'tenant_id'; sql_type: 'CHAR(36)']
	product_id string @[comment: '产品ID: wms/tms/mall'; immutable; sql_type: 'CHAR(36)']
	plan_id    string @[comment: '套餐ID'; sql_type: 'CHAR(36)']
	status     u8 @[comment: '0未开通 1已开通 2已关闭 3已过期'; default: 0; sql_type: 'smallint']
	updater_id ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
