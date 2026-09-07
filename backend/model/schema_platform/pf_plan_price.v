module schema_platform

import time

@[comment: '套餐定价表']
@[table: 'pf_plan_price']
pub struct PfPlanPrice {
pub:
	id         string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	plan_id    string @[comment: '套餐ID'; sql_type: 'CHAR(36)']
	cycle      string @[comment: '计费周期: monthly/yearly'; sql_type: 'VARCHAR(32)']
	amount     f64 @[comment: '金额'; sql_type: 'DECIMAL(12,2)']
	currency   string @[comment: '货币: CNY/USD'; sql_type: "VARCHAR(8) DEFAULT 'CNY'"]
	status     u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
