module schema_platform

import time

@[comment: '套餐定价表']
@[table: 'pf_plan_price']
pub struct PfPlanPrice {
pub:
	id         string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	plan_id    string     @[comment: '套餐ID'; sql_type: 'CHAR(36)']
	cycle      string     @[comment: '计费周期: monthly/yearly'; sql_type: 'VARCHAR(32)']
	amount     f64        @[comment: '金额'; sql_type: 'DECIMAL(12,2)']
	currency   string     @[comment: '货币: CNY/USD'; default: '"CNY"'; sql_type: 'VARCHAR(8)']
	status     u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
