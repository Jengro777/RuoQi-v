module schema_tenant

import time

// 关系说明：tenant_id → tn_tenant, workspace_id → ws_workspace, product_id → pf_product, portal_id → pf_portal；
// 入驻粒度是 workspace，用户权限通过 ws_member 和 ws_member_role 控制。
// 同一 workspace 可有多条入驻记录，支持多店铺（同一 workspace 对同一门户多次入驻）。
@[comment: '客户入住门户表（seller/buyer/owner/admin等）— subportal = subscription to a portal']
@[table: 'tn_subportal']
pub struct TnSubPortal {
pub:
	id           string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	tenant_id    string @[comment: '所属租户ID'; immutable; sql_type: 'CHAR(36)']
	product_id   string @[comment: '所属产品ID'; immutable; sql_type: 'CHAR(36)']
	portal_id    string @[comment: '门户ID: seller/buyer/owner/admin等'; immutable; sql_type: 'CHAR(36)']
	workspace_id string @[comment: '所属工作区ID'; sql: 'workspace_id'; sql_type: 'CHAR(36)']
	status       u8 @[comment: '0未订阅 1已订阅 2已取消'; default: 0; sql_type: 'smallint']
	updater_id   ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
