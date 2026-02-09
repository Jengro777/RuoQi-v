// ===========================
// module: usecase.sys_api.sys_admin.user
// ===========================
/*
usecase（应用服务层）
依赖 repo
依赖 domain
依赖 parts
依赖 dto
服务层串起所有层没问题
*/
module user

import time
import structs { Context }
import dto.sys_admin.user as dto { UserByIdResp }
import parts.sys_admin.user as _ { SysUserAggregate }
import domain.sys_admin.user as domain
import adapter.repository.user as repo_adapter

// 应用服务层入口
pub fn find_user_by_id_usecase(mut ctx Context, user_id string) !UserByIdResp {
	// Repository 实现了 Domain 层的接口, domain里的 interface
	mut repo := repo_adapter.UserRepo{
		ctx: &ctx
	}

	// 获取聚合对象
	agg := domain.get_user_aggregate_domain(mut repo, user_id)!

	// 转换为 API DTO 输出
	return map_user_aggregate_to_dto_parts(agg)
}

pub fn map_user_aggregate_to_dto_parts(agg SysUserAggregate) UserByIdResp {
	role_ids := agg.roles.map(it.id)
	role_names := agg.roles.map(it.name)

	data := dto.UserById{
		id:         agg.user.id
		username:   agg.user.username
		nickname:   agg.user.nickname
		status:     agg.user.status
		role_ids:   role_ids
		role_names: role_names
		avatar:     agg.user.avatar or { '' }
		desc:       agg.user.description or { '' }
		home_path:  agg.user.home_path
		mobile:     agg.user.mobile or { '' }
		email:      agg.user.email or { '' }
		creator_id: agg.user.creator_id or { '' }
		updater_id: agg.user.updater_id or { '' }
		created_at: agg.user.created_at.format_ss()
		updated_at: agg.user.updated_at.format_ss()
		deleted_at: (agg.user.deleted_at or { time.Time{} }).format_ss()
	}

	return UserByIdResp{
		datalist: [data]
	}
}
