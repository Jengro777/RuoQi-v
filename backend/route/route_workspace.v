module route

import log
import structs { Context }
import service.workspace_service.workspace_core { WorkspaceCore }
import service.workspace_service.workspace_department { WorkspaceDepartment }
import service.workspace_service.workspace_position { WorkspacePosition }

// =============================================================================
// Workspace 路由注册 — 工作区管理（IAM 认证 + datascope）
// =============================================================================

fn (mut app AliasApp) routes_workspace(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 工作区 CRUD + 成员 + 权限
	app.register_routes_iam[WorkspaceCore, Context](mut &WorkspaceCore{}, '/workspace/core', mut
		ctx)

	// 部门管理
	app.register_routes_iam[WorkspaceDepartment, Context](mut &WorkspaceDepartment{},
		'/workspace/department', mut ctx)

	// 岗位管理
	app.register_routes_iam[WorkspacePosition, Context](mut &WorkspacePosition{},
		'/workspace/position', mut ctx)
}
