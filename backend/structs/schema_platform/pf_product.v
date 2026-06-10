module schema_platform

import time

@[comment: '产品定义（WMS/TMS/Mall）']
@[table: 'pf_product']
pub struct PfProduct {
pub:
	id         string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	code       string     @[comment: '产品编码: wms/tms/mall'; sql_type: 'VARCHAR(64)']
	name       string     @[comment: '产品名称'; sql_type: 'VARCHAR(255)']
	icon       string     @[comment: '图标'; sql_type: 'VARCHAR(255)']
	status     u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
