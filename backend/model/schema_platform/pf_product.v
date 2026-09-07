module schema_platform

import time

@[comment: '产品定义（WMS/TMS/Mall）']
@[table: 'pf_product']
pub struct PfProduct {
pub:
	id           string @[comment: 'UUID'; immutable; primary; sql_type: 'CHAR(36)']
	product_code string @[comment: '产品编码: wms/tms/mall'; sql_type: 'VARCHAR(64)']
	product_name string @[comment: '产品显示名称: SAAS中台/商城/仓储'; sql_type: 'VARCHAR(255)']
	icon         string @[comment: '图标'; sql_type: 'VARCHAR(255)']
	status       u8 @[comment: '0: 停用/无效 1: 正常/有效'; default: 1; sql_type: 'smallint']
	updater_id   ?string @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at   time.Time @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id   ?string @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at   time.Time @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag     i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; sql_type: 'smallint']
	deleted_at   ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
