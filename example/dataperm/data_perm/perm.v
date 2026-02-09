module data_perm

// 数据权限结构体
pub struct DataPermContext {
pub mut:
	data_scope  string
	sub_dept    string
	custom_dept string
	role        string
	dept_id     string
	user_id     string
}
