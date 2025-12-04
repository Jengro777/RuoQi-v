module schema_core

import time

@[comment: '外部用户表']
@[table: 'core_user']
pub struct CoreUser {
pub:
	id            string  @[comment: 'UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)'; unique]
	username      string  @[comment: 'User`s login name | 登录名'; omitempty; required; sql: 'username'; sql_type: 'VARCHAR(255)'; unique: 'username']
	password      string  @[comment: 'Password | 密码'; omitempty; required; sql: 'password'; sql_type: 'VARCHAR(255)']
	password_salt string  @[comment: 'Password Salt | 密码盐'; omitempty; sql: 'password_salt'; sql_type: 'VARCHAR(255)']
	nickname      string  @[comment: 'Nickname | 昵称'; omitempty; sql_type: 'VARCHAR(255)'; unique: 'nickname']
	bio           ?string @[comment: '用户简介'; omitempty; sql_type: 'VARCHAR(255)']
	description   ?string @[comment: 'The description of user | 用户的描述信息'; omitempty; sql_type: 'VARCHAR(255)']
	home_path     string  @[comment: 'The home page that the user enters after logging in | 用户登陆后进入的首页'; default: '"/dashboard"'; omitempty; sql_type: 'VARCHAR(255)']
	phone         ?string @[comment: 'Mobile number | 手机号'; omitempty; sql_type: 'VARCHAR(255)']
	email         ?string @[comment: 'Email | 邮箱号'; omitempty; sql_type: 'VARCHAR(255)']
	avatar        ?string @[comment: 'Permanent Avatar | 永久头像路径'; omitempty; sql_type: 'VARCHAR(512)']
	status        u8      @[comment: '状态，0：正常，1：禁用'; default: 0; omitempty; sql_type: 'tinyint(20)']

	language     string  @[comment: '语言'; default: '"English"'; omitempty; sql_type: 'VARCHAR(255)']
	shiqu        string  @[comment: 'Shiqu'; default: '"UTC +00:00"'; omitempty; sql_type: 'VARCHAR(255)']
	id_card_type u8      @[comment: '证件类型，0：身份证，1：护照，2：军官证，3：其他'; default: 0; omitempty; sql_type: 'tinyint']
	id_card      ?string @[comment: '证件号码'; omitempty; sql_type: 'VARCHAR(255)']
	tag          ?string @[comment: '标签'; omitempty; sql_type: 'VARCHAR(255)']
	region       ?string @[comment: '地区'; omitempty; sql_type: 'VARCHAR(255)']
	gender       u8      @[comment: '性别，0：男，1：女，2：未知'; default: 0; omitempty; sql_type: 'tinyint']
	birthday     ?string @[comment: '生日'; omitempty; sql_type: 'VARCHAR(255)']

	education          u8      @[comment: '学历，0:未知，1：小学，2：初中，3：高中，4：大专，5：本科，6：硕士，7：博士'; default: 0; omitempty; sql_type: 'tinyint']
	score              u32     @[comment: '分数'; default: 0; omitempty; sql_type: 'INT']
	ranking            u32     @[comment: '排名'; default: 0; omitempty; sql_type: 'INT']
	is_online          bool    @[comment: '是否在线'; default: false; omitempty; sql_type: 'TINYINT']
	signup_application ?string @[comment: '注册申请'; omitempty; sql_type: 'VARCHAR(255)']
	hash               ?string @[comment: '哈希值'; omitempty; sql_type: 'VARCHAR(255)']
	pre_hash           ?string @[comment: '预哈希值'; omitempty; sql_type: 'VARCHAR(255)']

	created_ip       string    @[comment: '创建IP'; omitempty; sql_type: 'VARCHAR(255)']
	last_signin_time time.Time @[comment: '最后登录时间'; omitempty; sql_type: 'TIMESTAMP']
	last_signin_ip   string    @[comment: '最后登录IP'; omitempty; sql_type: 'VARCHAR(255)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
