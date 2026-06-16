module schema_iam

import time

@[comment: 'IAM API Key 表 — 长效机器凭据，AK+SK 模式']
@[table: 'iam_api_key']
pub struct IamApiKey {
pub:
	id      string @[primary; sql_type: 'CHAR(36)']
	user_id string @[comment: '所属用户ID'; sql_type: 'CHAR(36)']
	name    string @[comment: '密钥名称/备注'; sql_type: 'VARCHAR(255)']

	access_key_id string @[comment: 'Access Key ID'; sql_type: 'VARCHAR(64)'; unique]
	key_prefix    string @[comment: 'AK 显示前缀, 如"ak-ce995"'; sql_type: 'VARCHAR(16)']
	key_hash      string @[comment: 'SK 的 SHA256 哈希'; sql_type: 'CHAR(64)']
	key_last_four string @[comment: 'SK 末4位, UI 辅助识别'; sql_type: 'VARCHAR(4)']

	tenant_ids     string @[comment: '租户ID列表(JSON), 空=不限'; default: '[]'; sql_type: 'VARCHAR(1000)']
	subproduct_ids string @[comment: '订阅的产品ID列表(JSON), 空=不限'; default: '[]'; sql_type: 'VARCHAR(1000)']
	subportal_ids  string @[comment: '订阅产品的订阅门户ID列表(JSON), 空=不限'; default: '[]'; sql_type: 'VARCHAR(1000)']

	scopes       string     @[comment: 'API权限范围(JSON)'; default: '["all"]'; sql_type: 'VARCHAR(1000)']
	status       u8         @[comment: '0正常 1禁用 2已撤销'; default: 0; sql_type: 'tinyint']
	last_used_at ?time.Time @[comment: '最后使用时间'; sql_type: 'TIMESTAMP']
	expired_at   ?time.Time @[comment: '过期时间, null=永不过期'; sql_type: 'TIMESTAMP']

	// 审计字段（从 Common 混入展开，V ORM 不支持嵌入结构体的字段引用）
	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
