module schema_sys

import time

@[comment: '角色表']
@[table: 'sys_role']
pub struct SysRole {
pub:
	id              string  @[comment: 'UUID rand.uuid_v7()'; immutable; omitempty; primary; sql_type: 'CHAR(36)']
	name            string  @[comment: 'Role name | 角色名'; omitempty; sql_type: 'VARCHAR(255)']
	code            string  @[comment: 'Role code for permission control in front end | 角色码，用于前端权限控制'; omitempty; sql_type: 'VARCHAR(255)']
	default_router  string  @[comment: 'Default menu : dashboard | 默认登录页面'; default: '"/dashboard"'; omitempty; sql_type: 'VARCHAR(255)']
	remark          ?string @[comment: 'Remark | 备注'; omitempty; sql_type: 'VARCHAR(255)']
	sort            u32     @[comment: 'Order number | 排序编号'; default: 0; omitempty; sql_type: 'int']
	data_scope      u8      @[comment: 'Data scope 1 - all data 2 - custom dept data 3 - own dept and sub dept data 4 - own dept data  5 - your own data | 数据权限范围 1 - 所有数据 2 - 自定义部门数据 3 - 您所在部门及下属部门数据 4 - 您所在部门数据 5 - 本人数据'; default: 1; omitempty; sql_type: 'tinyint']
	custom_dept_ids ?string @[comment: 'Custom department setting for data permission | 自定义部门数据权限'; omitempty; sql_type: 'CHAR(36)']
	status          u8      @[comment: '状态，0：正常，1：禁用'; default: 0; omitempty; sql_type: 'tinyint']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
