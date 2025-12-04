module schema_pay

import time

// 支付退款表
@[table: 'pay_refund']
pub struct PayRefund {
pub:
	id                  string     @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	no                  string     @[comment: '退款单号'; omitempty; required; sql: 'no'; sql_type: 'VARCHAR(255)']
	channel_code        string     @[comment: '渠道编码'; omitempty; required; sql: 'channel_code'; sql_type: 'VARCHAR(255)']
	order_id            string     @[comment: '支付订单编号 pay_order 表id'; omitempty; required; sql: 'order_id'; sql_type: 'CHAR(36)']
	order_no            string     @[comment: '支付订单 no'; omitempty; required; sql: 'order_no'; sql_type: 'VARCHAR(255)']
	merchant_order_id   string     @[comment: '商户订单编号（商户系统生成）'; omitempty; required; sql: 'merchant_order_id'; sql_type: 'VARCHAR(255)']
	merchant_refund_id  string     @[comment: '商户退款订单号（商户系统生成）'; omitempty; required; sql: 'merchant_refund_id'; sql_type: 'VARCHAR(255)']
	pay_price           int        @[comment: '支付金额,单位分'; omitempty; required; sql: 'pay_price'; sql_type: 'int']
	refund_price        int        @[comment: '退款金额,单位分'; omitempty; required; sql: 'refund_price'; sql_type: 'int']
	reason              string     @[comment: '退款原因'; omitempty; required; sql: 'reason'; sql_type: 'VARCHAR(255)']
	user_ip             ?string    @[comment: '用户 IP'; omitempty; sql: 'user_ip'; sql_type: 'VARCHAR(255)']
	channel_order_no    string     @[comment: '渠道订单号，pay_order 中的 channel_order_no 对应'; omitempty; required; sql: 'channel_order_no'; sql_type: 'VARCHAR(255)']
	channel_refund_no   ?string    @[comment: '渠道退款单号，渠道返回'; omitempty; sql: 'channel_refund_no'; sql_type: 'VARCHAR(255)']
	success_time        ?time.Time @[comment: '退款成功时间'; omitempty; sql: 'success_time'; sql_type: 'TIMESTAMP']
	channel_error_code  ?string    @[comment: '渠道调用报错时，错误码'; omitempty; sql: 'channel_error_code'; sql_type: 'VARCHAR(255)']
	channel_error_msg   ?string    @[comment: '渠道调用报错时，错误信息'; omitempty; sql: 'channel_error_msg'; sql_type: 'VARCHAR(255)']
	channel_notify_data ?string    @[comment: '支付渠道异步通知的内容'; omitempty; sql: 'channel_notify_data'; sql_type: 'longtext']
	status              u8         @[comment: 'Status 1: normal 2: ban | 状态 1 正常 2 禁用'; default: 1; omitempty; sql: 'status'; sql_type: 'tinyint unsigned']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
