module schema_iam

@[comment: 'IAM 用户角色关联表']
@[unique_key: 'user_id,role_id']
@[table: 'iam_user_role']
pub struct IamUserRole {
pub:
	user_id string @[comment: '用户ID'; sql_type: 'CHAR(36)']
	role_id string @[comment: '角色ID'; sql_type: 'CHAR(36)']
}
