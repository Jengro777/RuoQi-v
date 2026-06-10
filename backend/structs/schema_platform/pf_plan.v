module schema_platform

import time

@[comment: '套餐定义（基础版/企业版/旗舰版）']
@[table: 'pf_plan']
pub struct PfPlan {
pub:
	id          string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	product_id  string     @[comment: '所属产品ID'; sql_type: 'CHAR(36)']
	name        string     @[comment: '套餐名称'; sql_type: 'VARCHAR(255)']
	code        string     @[comment: '套餐编码: basic/enterprise/ultimate'; sql_type: 'VARCHAR(64)']
	description string     @[comment: '描述'; sql_type: 'VARCHAR(500)']
	status      u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id  string     @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  string     @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
