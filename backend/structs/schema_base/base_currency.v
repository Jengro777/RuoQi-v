module schema_base

import time

@[table: 'base_currency']
@[comment: '货币表']
pub struct BaseCurrency {
pub:
	id                        string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	english_name              string @[comment: '货币名称:English'; required; sql_type: 'VARCHAR(255)']
	simplified_name           string @[comment: '货币名称:简体中文'; required; sql_type: 'VARCHAR(255)']
	currency_code             string @[comment: '货币代码'; required; sql_type: 'VARCHAR(10)']
	currency_symbol           string @[comment: '货币符号'; required; sql_type: 'VARCHAR(10)']
	decimal_place             u8     @[comment: '小数位数'; default: 5; required; sql_type: 'TINYINT UNSIGNED']
	exchange_rate             f64    @[comment: '汇率'; required; sql_type: 'DOUBLE']
	exchange_rate_fluctuation f64    @[comment: '汇率波动'; required; sql_type: 'DOUBLE']
	exchange_rate_used        f64    @[comment: '使用的汇率'; required; sql_type: 'DOUBLE']
	sort                      ?int   @[comment: 'Sort Number | 排序编号'; sql_type: 'INT UNSIGNED']
	status                    u8     @[comment: 'Status  0: active 1: inactive | 状态'; default: 0; sql_type: 'TINYINT UNSIGNED']

	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '逻辑删除，0：未删除，1：已删除'; default: 0; sql_type: 'TINYINT UNSIGNED']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; sql_type: 'TIMESTAMP']
}
