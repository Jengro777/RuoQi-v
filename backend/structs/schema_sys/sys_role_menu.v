module schema_sys

@[comment: '角色菜单关联表(一个角色可以拥有多个菜单)']
@[unique_key: 'role_id,menu_id']
@[table: 'sys_role_menu']
pub struct SysRoleMenu {
pub:
	role_id string @[comment: '角色ID'; sql_type: 'CHAR(36)']
	menu_id string @[comment: '菜单ID'; sql_type: 'CHAR(36)']
}
