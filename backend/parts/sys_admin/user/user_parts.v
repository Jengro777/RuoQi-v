// ===========================
// module: parts.sys_admin.user
// ===========================
/*
parts（领域数据结构，可复用定义）
不依赖 dto
被 repo、domain、services 使用
*/
module user

import time
import structs.schema_sys { SysRole, SysUser }

// ---- 轻量 mapper（最小侵入版本） ----
pub fn to_user_part(entity SysUser) SysUserPart {
	return SysUserPart{
		id:          entity.id
		username:    entity.username
		nickname:    entity.nickname
		status:      entity.status
		avatar:      entity.avatar
		description: entity.description
		home_path:   entity.home_path
		mobile:      entity.mobile
		email:       entity.email
		creator_id:  entity.creator_id
		updater_id:  entity.updater_id
		created_at:  entity.created_at
		updated_at:  entity.updated_at
		deleted_at:  entity.deleted_at
	}
}

pub fn to_role_part(entity SysRole) SysRolePart {
	return SysRolePart{
		id:   entity.id
		name: entity.name
	}
}

// ===== 领域模型部分对象 (Entity/Value Object) =====
// DDD 中的 Part 是聚合的一部分，可以组合成 Aggregate

pub struct SysUserPart {
pub mut:
	id          string
	username    string
	nickname    string
	status      u8
	avatar      ?string
	description ?string
	home_path   string
	mobile      ?string
	email       ?string
	creator_id  ?string
	updater_id  ?string
	created_at  time.Time
	updated_at  time.Time
	deleted_at  ?time.Time
}

pub struct SysRolePart {
pub mut:
	id   string
	name string
}

// 聚合根
pub struct SysUserAggregate {
pub mut:
	user  SysUserPart
	roles []SysRolePart
}
