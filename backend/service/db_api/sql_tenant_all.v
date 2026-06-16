module db_api

pub const tn_tenant = r"
REPLACE INTO `tn_tenant` (`id`, `owner_id`, `logo_url`, `name`, `type`, `slug`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '/logo', '我的团队', 1, 'my-team', 1, NULL, '2025-11-04 10:26:46', NULL, '2025-11-04 10:26:44', 0, NULL);
"
