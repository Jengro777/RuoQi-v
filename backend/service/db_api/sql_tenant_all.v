module db_api

import time
import orm
import model.schema_tenant

pub fn tenant_upsert(db orm.Connection) ! {
	for item in tn_tenant() {
		sql db {
			upsert item into schema_tenant.TnTenant
		} or { return err }
	}
	for item in tn_subportal() {
		sql db {
			upsert item into schema_tenant.TnSubPortal
		} or { return err }
	}
	for item in tn_member() {
		sql db {
			upsert item into schema_tenant.TnMember
		} or { return err }
	}
}

fn tn_tenant() []schema_tenant.TnTenant {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_tenant.TnTenant{ id: '00000000-0000-0000-0000-000000000001', owner_id: '00000000-0000-0000-0000-000000000001', logo_url: '/logo', name: '我的团队', type: 1, slug: 'my-team', status: 1, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}

fn tn_subportal() []schema_tenant.TnSubPortal {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_tenant.TnSubPortal{ id: '00000000-0000-0000-0000-000000000001', tenant_id: '00000000-0000-0000-0000-000000000001', product_id: '00000000-0000-0000-0000-000000000002', portal_id: '00000000-0000-0000-0000-000000000003', workspace_id: '00000000-0000-0000-0000-000000000001', status: 1, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}

fn tn_member() []schema_tenant.TnMember {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_tenant.TnMember{ tenant_id: '00000000-0000-0000-0000-000000000001', user_id: '00000000-0000-0000-0000-000000000001', product_id: '00000000-0000-0000-0000-000000000002', portal_id: '00000000-0000-0000-0000-000000000003', status: 1, joined_at: t, updater_id: none, updated_at: t, creator_id: none, created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}
