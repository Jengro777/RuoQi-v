// TEMPLATE: Schema struct — copy to structs/schema_xxx/xxx.v
// Replace Xxx, xxx with actual names.
// Schema defines the database table mapping for V ORM.
import time

@[comment: 'Description of this entity']
@[table: 'xxx']
pub struct Xxx {
pub:
	id   string @[comment: 'Primary key UUID'; immutable; primary; required; sql_type: 'CHAR(36)'; unique]
	name string @[comment: 'Name'; required; sql_type: 'VARCHAR(100)']
	// Add domain-specific fields here

	// Standard lifecycle fields (required for soft-delete)
	status     u8         @[comment: 'Status, 0:inactive 1:active'; default: 0; sql_type: 'tinyint(1)']
	updater_id ?string    @[comment: 'Updater ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: 'Creator ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: 'Delete flag, 0:not deleted 1:deleted'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time'; omitempty; sql_type: 'TIMESTAMP']
}
