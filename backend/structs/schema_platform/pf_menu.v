module schema_platform

import time

@[comment: '平台菜单表']
@[table: 'pf_menu']
pub struct PfMenu {
pub:
	id         string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	parent_id  string     @[default: '0'; sql_type: 'CHAR(36)']
	menu_level u8         @[comment: '菜单级别: 0目录 1菜单 2按钮'; sql_type: 'tinyint(1)']
	menu_type  u8         @[comment: '菜单类型: 0目录 1菜单 2按钮'; sql_type: 'tinyint(1)']
	path       string     @[comment: '路由路径'; sql_type: 'VARCHAR(255)']
	name       string     @[comment: '菜单名称'; sql_type: 'VARCHAR(255)']
	redirect   string     @[comment: '重定向路径'; sql_type: 'VARCHAR(255)']
	component  string     @[comment: '前端组件路径'; sql_type: 'VARCHAR(255)']
	order_no   u32        @[comment: '排序号'; default: 0; sql_type: 'int']
	icon       string     @[comment: '图标'; sql_type: 'VARCHAR(255)']
	title      string     @[comment: '标题'; sql_type: 'VARCHAR(255)']
	status     u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
