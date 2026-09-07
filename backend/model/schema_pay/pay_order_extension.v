module schema_pay

import time

// 支付订单扩展表
@[table: 'pay_order_extension']
pub struct PayOrderExtension {
pub:
	id                  string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	no                  string @[comment: '支付订单号'; omitempty; required; sql: 'no'; sql_type: 'VARCHAR(255)']
	order_id            string @[comment: '支付订单ID → pay_order.id'; omitempty; required; sql: 'order_id'; sql_type: 'CHAR(36)']
	channel_code        string @[comment: '渠道编码'; omitempty; required; sql: 'channel_code'; sql_type: 'VARCHAR(255)']
	user_ip             string @[comment: '用户 IP'; omitempty; required; sql: 'user_ip'; sql_type: 'VARCHAR(255)']
	channel_extras      ?string @[comment: '支付渠道的额外参数'; omitempty; sql: 'channel_extras'; sql_type: 'json']
	channel_error_code  ?string @[comment: '调用渠道的错误码'; omitempty; sql: 'channel_error_code'; sql_type: 'VARCHAR(255)']
	channel_error_msg   ?string @[comment: '调用渠道报错时，错误信息'; omitempty; sql: 'channel_error_msg'; sql_type: 'VARCHAR(255)']
	channel_notify_data ?string @[comment: '支付渠道异步通知的内容'; omitempty; sql: 'channel_notify_data'; sql_type: 'text']
	status              u8 @[comment: 'Status 0: ban 1: normal | 状态 0 禁用 1 正常'; default: 1; omitempty; sql: 'status'; sql_type: 'smallint']

	updater_id ?string @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; omitempty; sql_type: 'smallint']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
