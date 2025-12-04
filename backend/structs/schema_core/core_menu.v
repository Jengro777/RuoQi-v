module schema_core

import time

@[unique_key: 'path,service_name']
@[comment: '菜单表']
@[table: 'core_menu']
pub struct CoreMenu {
pub:
	id                    string  @[comment: 'UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	parent_id             ?string @[comment: 'Parent menu ID | 父菜单ID'; immutable; sql: 'parent_id'; sql_type: 'CHAR(36)']
	menu_level            u64     @[comment: 'Menu level | 菜单层级'; omitempty; sql_type: 'int']
	menu_type             u64     @[comment: 'Menu type | 菜单类型 （菜单或目录）0 目录 1 菜单 2 页面元素'; omitempty; sql_type: 'int']
	path                  ?string @[comment: 'Index path | 菜单路由路径'; omitempty; sql_type: 'VARCHAR(255)']
	name                  string  @[comment: 'Index name | 菜单名称'; omitempty; sql_type: 'VARCHAR(255)']
	redirect              ?string @[comment: ' Redirect path | 跳转路径 （外链）'; omitempty; sql_type: 'VARCHAR(255)']
	component             ?string @[comment: 'The path of vue file | 组件路径'; omitempty; sql_type: 'VARCHAR(255)']
	disabled              ?u8     @[comment: 'Disable status | 是否停用'; default: 0; omitempty; sql_type: 'tinyint(1)']
	service_name          string  @[comment: 'Service Name | 服务名称'; default: '"Tenant"'; omitempty; sql_type: 'VARCHAR(255)']
	permission            ?string @[comment: 'Permission symbol | 权限标识'; omitempty; sql_type: 'VARCHAR(255)']
	title                 string  @[comment: 'Menu name | 菜单显示标题'; omitempty; sql_type: 'VARCHAR(255)']
	icon                  string  @[comment: 'Menu icon | 菜单图标'; omitempty; sql_type: 'VARCHAR(255)']
	hide_menu             ?u8     @[comment: 'Hide menu | 是否隐藏菜单'; default: 0; omitempty; sql_type: 'tinyint(1)']
	hide_breadcrumb       ?u8     @[comment: 'Hide the breadcrumb | 隐藏面包屑'; default: 0; omitempty; sql_type: 'tinyint(1)']
	ignore_keep_alive     ?u8     @[comment: 'Do not keep alive the tab | 取消页面缓存'; default: 0; omitempty; sql_type: 'tinyint(1)']
	hide_tab              ?u8     @[comment: 'Hide the tab header | 隐藏页头'; default: 0; omitempty; sql_type: 'tinyint(1)']
	frame_src             ?string @[comment: 'Show iframe | 内嵌 iframe'; omitempty; sql_type: 'VARCHAR(255)']
	carry_param           ?u8     @[comment: 'The route carries parameters or not | 携带参数'; default: 0; omitempty; sql_type: 'tinyint(1)']
	hide_children_in_menu ?u8     @[comment: 'Hide children menu or not | 隐藏所有子菜单'; default: 0; omitempty; sql_type: 'tinyint(1)']
	affix                 ?u8     @[comment: 'Affix tab | Tab 固定'; default: 0; omitempty; sql_type: 'tinyint(1)']
	dynamic_level         ?u32    @[comment: 'The maximum number of pages the router can open | 能打开的子TAB数'; default: 20; omitempty; sql_type: 'int']
	real_path             ?string @[comment: 'The real path of the route without dynamic part | 菜单路由不包含参数部分'; omitempty; sql_type: 'VARCHAR(255)']
	sort                  u32     @[comment: 'Sort Number | 排序编号'; default: 0; omitempty; sql_type: 'int']
	source_type           string  @[comment: '来源类型: tenant/app'; sql_type: 'VARCHAR(32)']
	source_id             string  @[comment: '来源ID: app_id或tenant_id'; sql_type: 'CHAR(36)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
