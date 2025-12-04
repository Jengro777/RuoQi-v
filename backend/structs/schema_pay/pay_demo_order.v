module schema_pay

import time

// 支付示例订单表
@[table: 'pay_demo_order']
pub struct PayDemoOrder {
pub:
	id               string     @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	user_id          string     @[comment: '用户编号'; omitempty; required; sql: 'user_id'; sql_type: 'VARCHAR(255)']
	spu_id           u64        @[comment: '商品编号'; omitempty; required; sql: 'spu_id'; sql_type: 'bigint unsigned']
	spu_name         string     @[comment: '商品名称'; omitempty; required; sql: 'spu_name'; sql_type: 'VARCHAR(255)']
	price            int        @[comment: '价格，单位：分'; omitempty; required; sql: 'price'; sql_type: 'int']
	pay_status       u8         @[comment: '是否支付'; omitempty; required; sql: 'pay_status'; sql_type: 'tinyint(1)']
	pay_order_id     ?u64       @[comment: '支付订单编号'; omitempty; sql: 'pay_order_id'; sql_type: 'bigint unsigned']
	pay_time         ?time.Time @[comment: '付款时间'; default: now; omitempty; sql: 'pay_time'; sql_type: 'TIMESTAMP']
	pay_channel_code ?string    @[comment: '支付渠道'; omitempty; sql: 'pay_channel_code'; sql_type: 'VARCHAR(255)']
	pay_refund_id    ?u64       @[comment: '支付退款单号'; omitempty; sql: 'pay_refund_id'; sql_type: 'bigint unsigned']
	refund_price     ?int       @[comment: '退款金额，单位：分'; omitempty; sql: 'refund_price'; sql_type: 'int']
	refund_time      ?time.Time @[comment: '退款完成时间'; default: now; omitempty; sql: 'refund_time'; sql_type: 'TIMESTAMP']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
