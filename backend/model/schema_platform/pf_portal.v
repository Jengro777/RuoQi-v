module schema_platform

import time

// unique_key 说明：同一产品下门户编码唯一，防止重复定义；
// 同一编码可跨产品存在（如 Mall 和 WMS 各有 seller 门户）。
// portal_type 区分鉴权方式：
//   0 = platform  — 中台专用，平台级管理
//   1 = tn_member — 会员端，查 TnMember（用户↔租户↔产品↔门户）
//   2 = ws_member — 业务端，查 WsMember → WsRole（用户↔工作区↔角色）
@[comment: '门户定义表（seller/buyer/owner/admin 等）— 产品下有哪些门户']
@[unique_key: 'product_id,portal_code']
@[table: 'pf_portal']
pub struct PfPortal {
pub:
	id          string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	product_id  string @[comment: '所属产品ID'; sql_type: 'CHAR(36)']
	portal_code string @[comment: '门户编码: seller/buyer/owner/admin'; sql_type: 'VARCHAR(64)']
	portal_name string @[comment: '门户显示名称: Mall_买家端/店铺端等'; sql_type: 'VARCHAR(255)']
	portal_type u8 @[comment: '0 SAAS中台, 1 tn_member会员端 ,2 ws_member业务端'; immutable; sql_type: 'smallint']
	description string @[comment: '门户描述'; sql_type: 'VARCHAR(500)']
	status      u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id  ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
