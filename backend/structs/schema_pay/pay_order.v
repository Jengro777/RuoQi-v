module schema_pay

import time

// 支付订单表
@[table: 'pay_order']
pub struct PayOrder {
pub:
	id                string     @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	channel_code      ?string    @[comment: '渠道编码'; omitempty; sql: 'channel_code'; sql_type: 'VARCHAR(255)']
	merchant_order_id string     @[comment: '商户订单编号'; omitempty; required; sql: 'merchant_order_id'; sql_type: 'VARCHAR(255)']
	subject           string     @[comment: '商品标题'; omitempty; required; sql: 'subject'; sql_type: 'VARCHAR(255)']
	body              string     @[comment: '商品描述'; omitempty; required; sql: 'body'; sql_type: 'VARCHAR(255)']
	price             int        @[comment: '支付金额，单位：分'; omitempty; required; sql: 'price'; sql_type: 'int']
	channel_fee_rate  ?f64       @[comment: '渠道手续费，单位：百分比'; omitempty; sql: 'channel_fee_rate'; sql_type: 'double']
	channel_fee_price ?int       @[comment: '渠道手续金额，单位：分'; omitempty; sql: 'channel_fee_price'; sql_type: 'int']
	user_ip           string     @[comment: '用户 IP'; omitempty; required; sql: 'user_ip'; sql_type: 'VARCHAR(255)']
	expire_time       time.Time  @[comment: '订单失效时间'; default: now; omitempty; required; sql: 'expire_time'; sql_type: 'TIMESTAMP']
	success_time      ?time.Time @[comment: '订单支付成功时间'; default: now; omitempty; sql: 'success_time'; sql_type: 'TIMESTAMP']
	notify_time       ?time.Time @[comment: '订单支付通知时间'; default: now; omitempty; sql: 'notify_time'; sql_type: 'TIMESTAMP']
	extension_id      ?string    @[comment: '支付成功的订单拓展单编号'; omitempty; sql: 'extension_id'; sql_type: 'CHAR(36)']
	no                ?string    @[comment: '订单号'; omitempty; sql: 'no'; sql_type: 'VARCHAR(255)']
	refund_price      int        @[comment: '退款总金额，单位：分'; omitempty; required; sql: 'refund_price'; sql_type: 'int']
	channel_user_id   ?string    @[comment: '渠道用户编号'; omitempty; sql: 'channel_user_id'; sql_type: 'VARCHAR(255)']
	channel_order_no  ?string    @[comment: '渠道订单号'; omitempty; sql: 'channel_order_no'; sql_type: 'VARCHAR(255)']
	status            u8         @[comment: 'Status 1: normal 2: ban | 状态 1 正常 2 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint unsigned']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
