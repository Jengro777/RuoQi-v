// ===========================
// module: domain.sys_admin.user
// ===========================
/*
domain（领域逻辑）
依赖 parts
不依赖 repo、不依赖 dto（非常干净）
*/
module user

import parts.sys_admin.user { SysRolePart, SysUserAggregate, SysUserPart }

// Domain 层接口不变
pub interface UserRepository {
mut:
	find_user_by_id(user_id string) !SysUserPart
	find_roles_by_user_id(user_id string) ![]SysRolePart
}

// Domain 组合聚合逻辑（只做轻量清理，不拆分）
pub fn get_user_aggregate_domain(mut r UserRepository, user_id string) !SysUserAggregate {
	if user_id == '' {
		return error('user_id cannot be empty')
	}

	user_info := r.find_user_by_id(user_id)!
	roles := r.find_roles_by_user_id(user_id)!

	return SysUserAggregate{
		user:  user_info
		roles: roles
	}
}
