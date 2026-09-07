module db_api

import time
import orm
import model.schema_iam

pub fn iam_upsert(db orm.Connection) ! {
	for item in iam_user() {
		sql db {
			upsert item into schema_iam.IamUser
		} or { return err }
	}
}

fn iam_user() []schema_iam.IamUser {
	t := time.parse('2027-01-01 00:00:00') or { time.now() }
	// vfmt off
	return [
		schema_iam.IamUser{ id: '00000000-0000-0000-0000-000000000001', username: 'admin', password: '$2a$10$3VG4yDmIBpMmNesQAtVXAenUMAif4BDvR/gHcqPv5vZAw7TmPHCZq', nickname: 'administrator', description: '所有者', home_path: '/dashboard', mobile: '', email: '', avatar: '/avatar', status: 1, updater_id: '', updated_at: t, creator_id: '', created_at: t, del_flag: 0, deleted_at: none },
	]
	// vfmt on
}
