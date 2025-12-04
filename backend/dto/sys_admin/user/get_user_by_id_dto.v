// ===========================
// module: dto.sys_admin.user
// ===========================
/*
dto（数据传输层）
最底层
无依赖
被 handler、services、parts 使用
*/
module user

pub struct UserByIdReq {
pub:
	user_id string
}

pub struct UserByIdResp {
pub:
	datalist []UserById
}

pub struct UserById {
pub:
	id         string
	username   string
	nickname   string
	status     u8
	role_ids   []string
	role_names []string
	avatar     string
	desc       string
	home_path  string
	mobile     string
	email      string
	creator_id string
	updater_id string
	created_at string
	updated_at string
	deleted_at string
}
