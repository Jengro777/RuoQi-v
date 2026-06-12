module schema_tenant

import time

@[comment: '客户入住门户表（seller/buyer/owner/admin等）— subportal = subscription to a portal']
@[table: 'tn_subportal']
pub struct TnSubPortal {
pub:
	id            string     @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	workspace_id  string     @[comment: '所属工作区ID'; sql: 'workspace_id'; sql_type: 'CHAR(36)']
	subproduct_id string     @[comment: '所属租户产品订阅实例ID'; sql_type: 'CHAR(36)']
	portal_id     string     @[comment: '门户ID: seller/buyer/owner/admin等'; immutable; sql_type: 'CHAR(36)']
	user_id       string     @[comment: '所属客户ID'; immutable; sql_type: 'CHAR(36)']
	status        u8         @[comment: '0未订阅 1已订阅 2已取消'; default: 0; sql_type: 'tinyint(20)']
	updater_id    ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at    time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id    ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at    time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag      u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at    ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
