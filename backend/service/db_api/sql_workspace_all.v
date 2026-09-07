module db_api

import time
import orm
import model.schema_workspace

pub fn workspace_upsert(db orm.Connection) ! {
	for item in ws_workspace() {
		sql db {
			upsert item into schema_workspace.WsWorkspace
		} or { return err }
	}
	for item in ws_role() {
		sql db {
			upsert item into schema_workspace.WsRole
		} or { return err }
	}
	for item in ws_member() {
		sql db {
			upsert item into schema_workspace.WsMember
		} or { return err }
	}
	for item in ws_member_role() {
		sql db {
			upsert item into schema_workspace.WsMemberRole
		} or { return err }
	}
	for item in ws_department() {
		sql db {
			upsert item into schema_workspace.WsDepartment
		} or { return err }
	}
	for item in ws_position() {
		sql db {
			upsert item into schema_workspace.WsPosition
		} or { return err }
	}
}

fn ws_workspace() []schema_workspace.WsWorkspace {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_workspace.WsWorkspace{ id: '00000000-0000-0000-0000-000000000001', tenant_id: '00000000-0000-0000-0000-000000000001', name: '默认工作区', description: '系统默认工作区', status: 1, updater_id: '', updated_at: t, creator_id: '', created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}

fn ws_role() []schema_workspace.WsRole {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_workspace.WsRole{ id: '00000000-0000-0000-0000-000000000001', workspace_id: '00000000-0000-0000-0000-000000000001', name: '空间管理员', code: 'workspace_admin', description: '默认工作区管理员角色', sort: 1, status: 1, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}

fn ws_member() []schema_workspace.WsMember {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_workspace.WsMember{ workspace_id: '00000000-0000-0000-0000-000000000001', user_id: '00000000-0000-0000-0000-000000000001', joined_at: t, status: 1, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}

fn ws_member_role() []schema_workspace.WsMemberRole {
	// vfmt off
	return [
		schema_workspace.WsMemberRole{ workspace_id: '00000000-0000-0000-0000-000000000001', user_id: '00000000-0000-0000-0000-000000000001', role_id: '00000000-0000-0000-0000-000000000001' },
	]
	// vfmt on
}

fn ws_department() []schema_workspace.WsDepartment {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_workspace.WsDepartment{ id: '00000000-0000-0000-0000-000000000001', workspace_id: '00000000-0000-0000-0000-000000000001', parent_id: '0', name: '默认部门', code: 'default', description: '系统默认部门', sort: 1, status: 1, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}

fn ws_position() []schema_workspace.WsPosition {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_workspace.WsPosition{ id: '00000000-0000-0000-0000-000000000001', workspace_id: '00000000-0000-0000-0000-000000000001', name: '默认岗位', code: 'default', description: '系统默认岗位', sort: 1, status: 1, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}
