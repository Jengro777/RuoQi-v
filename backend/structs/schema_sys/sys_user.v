module schema_sys

import time

@[comment: ' 用户表']
@[table: 'sys_user']
pub struct SysUser {
pub:
	id          string  @[comment: 'UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	username    string  @[comment: 'User`s login name | 登录名'; omitempty; required; sql: 'username'; sql_type: 'VARCHAR(255)'; unique: 'username']
	password    string  @[comment: 'Password | 密码'; omitempty; required; sql: 'password'; sql_type: 'VARCHAR(255)']
	nickname    string  @[comment: 'Nickname | 昵称'; omitempty; sql_type: 'VARCHAR(255)'; unique: 'nickname']
	description ?string @[comment: 'The description of user | 用户的描述信息'; omitempty; sql_type: 'VARCHAR(255)']
	home_path   string  @[comment: 'The home page that the user enters after logging in | 用户登陆后进入的首页'; default: '"/dashboard"'; omitempty; sql_type: 'VARCHAR(255)']
	mobile      ?string @[comment: 'Mobile number | 手机号'; omitempty; sql_type: 'VARCHAR(255)']
	email       ?string @[comment: 'Email | 邮箱号'; omitempty; sql_type: 'VARCHAR(255)']
	avatar      ?string @[comment: 'Avatar | 头像路径'; omitempty; sql_type: 'VARCHAR(512)']
	is_root     u8      @[comment: 'root用户拥有所有权限，0：否，1：是'; default: 0; omitempty; sql_type: 'tinyint(1)']
	status      u8      @[comment: '状态，0：正常，1：禁用'; default: 0; omitempty; sql_type: 'tinyint']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
