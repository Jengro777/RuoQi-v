module schema_workspace

import time

@[comment: '工作区订阅应用端表（WMS货主端/TMS企业端等）']
@[unique_key: 'workspace_id,application_id']
@[table: 'ws_subapp']
pub struct WsSubApp {
pub:
	id             string     @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	workspace_id   string     @[comment: '工作区ID'; immutable; sql: 'workspace_id'; sql_type: 'CHAR(36)']
	product_id     string     @[comment: '所属产品ID: wms/tms/mall'; sql_type: 'CHAR(36)']
	application_id string     @[comment: '应用端ID: wms_owner/tms_enterprise等'; immutable; sql_type: 'CHAR(36)']
	status         u8         @[comment: '0未订阅 1已订阅 2已取消'; default: 0; sql_type: 'tinyint(20)']
	updater_id     ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at     time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id     ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at     time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag       u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at     ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
