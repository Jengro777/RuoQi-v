// TEMPLATE: Schema struct — copy to backend/structs/schema_xxx/xxx.v
// Replace Xxx, xxx with actual names.
// Defines the database table mapping for V ORM.
import time

@[comment: 'xxx 表 | Xxx Table']
@[table: 'xxx']
pub struct Xxx {
pub:
	id string @[comment: 'UUID 主键 | Primary Key UUID'; primary; sql_type: 'CHAR(36)']

	// ... domain-specific fields ...
	// Standard lifecycle fields (soft-delete)
	status     u8         @[comment: '状态 | 0正常 1禁用 | Status: 0 active, 1 disabled'; default: 0; sql_type: 'tinyint']
	updater_id string     @[comment: '修改者ID | Updater ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期 | Updated At'; sql_type: 'TIMESTAMP']
	creator_id string     @[comment: '创建者ID | Creator ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期 | Created At'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记 | 0未删除 1已删除 | Delete Flag'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期 | Deleted At'; sql_type: 'TIMESTAMP']
}
