module schema_tenant

import time

// unique_key 说明：同一租户下同一用户对同一产品的同一门户只能有一条记录；
// 用户可加入多个产品/门户（多行），每个门户有独立的注册/授权流程和生命周期。
// 用途：会员/顾客等非管理员用户直连租户+产品+门户，不经过 workspace。
// 管理员权限走 WsMember → WsRole 体系，与此表无关。
// 前置条件：插入前必须验证对应 TnSubPortal 存在
//  （即 tenant_id+product_id+portal_id 已有入驻记录），
//  否则拒绝插入。校验函数见 validate_tn_member_subportal_exists()。
@[comment: '租户成员表（用户↔租户↔产品↔门户，不绑定 workspace）']
@[unique_key: 'tenant_id,product_id,portal_id,user_id']
@[table: 'tn_member']
pub struct TnMember {
pub:
	tenant_id  string @[comment: '租户ID→tn_tenant.id'; sql_type: 'CHAR(36)']
	product_id string @[comment: '产品ID→pf_product.id'; sql_type: 'CHAR(36)']
	portal_id  string @[comment: '门户ID→pf_portal.id'; sql_type: 'CHAR(36)']
	user_id    string @[comment: '用户ID→iam_user.id'; sql_type: 'CHAR(36)']
	status     u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	joined_at  time.Time @[comment: '加入日期'; sql_type: 'TIMESTAMP']
	updater_id ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
