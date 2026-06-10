module schema_tenant

import time

@[comment: '租户账单表']
@[table: 'tn_invoice']
pub struct TnInvoice {
pub:
	id              string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	tenant_id       string     @[comment: '租户ID'; sql_type: 'CHAR(36)']
	subscription_id string     @[comment: '订阅ID'; sql_type: 'CHAR(36)']
	amount          f64        @[comment: '金额'; sql_type: 'DECIMAL(12,2)']
	currency        string     @[comment: '货币'; default: '"CNY"'; sql_type: 'VARCHAR(8)']
	status          u8         @[comment: '0待支付 1已支付 2逾期 3已取消'; default: 0; sql_type: 'tinyint']
	period_start    time.Time  @[comment: '账期开始'; sql_type: 'TIMESTAMP']
	period_end      time.Time  @[comment: '账期结束'; sql_type: 'TIMESTAMP']
	paid_at         ?time.Time @[comment: '支付时间'; sql_type: 'TIMESTAMP']
	updater_id      ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at      time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id      ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at      time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag        u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at      ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
