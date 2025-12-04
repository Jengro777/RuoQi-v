module schema_msg

import time

// 邮件服务提供商表
@[table: 'msg_email_provider']
pub struct MsgEmailProvider {
pub:
	id         string  @[auto_inc; comment: 'UUID'; primary; sql: 'id'; sql_type: 'CHAR(36)']
	name       string  @[comment: 'The email provider name | 电子邮件服务的提供商'; omitempty; required; sql: 'name'; sql_type: 'VARCHAR(255)'; unique: 'name']
	auth_type  u8      @[comment: 'The auth type, supported plain, CRAMMD5 | 鉴权类型, 支持 plain, CRAMMD5'; omitempty; required; sql: 'auth_type'; sql_type: 'tinyint unsigned']
	email_addr string  @[comment: 'The email address | 邮箱地址'; omitempty; required; sql: 'email_addr'; sql_type: 'VARCHAR(255)']
	password   ?string @[comment: 'The email`s password | 电子邮件的密码'; omitempty; sql: 'password'; sql_type: 'VARCHAR(255)']
	host_name  string  @[comment: 'The host name is the email service`s host address | 电子邮箱服务的服务器地址'; omitempty; required; sql: 'host_name'; sql_type: 'VARCHAR(255)']
	identify   ?string @[comment: 'The identify info, for CRAMMD5 | 身份信息, 支持 CRAMMD5'; omitempty; sql: 'identify'; sql_type: 'VARCHAR(255)']
	secret     ?string @[comment: 'The secret, for CRAMMD5 | 邮箱密钥, 用于 CRAMMD5'; omitempty; sql: 'secret'; sql_type: 'VARCHAR(255)']
	port       ?u32    @[comment: 'The port of the host | 服务器端口'; omitempty; sql: 'port'; sql_type: 'int unsigned']
	tls        u8      @[comment: 'Whether to use TLS | 是否采用 tls 加密'; default: 0; omitempty; sql: 'tls'; sql_type: 'tinyint(1)']
	is_default u8      @[comment: 'Is it the default provider | 是否为默认提供商'; default: 0; omitempty; sql: 'is_default'; sql_type: 'tinyint(1)']

	updater_id ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}
