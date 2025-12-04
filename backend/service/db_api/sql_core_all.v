module db_api

pub const core_api = r"
REPLACE INTO `core_api` (`id`, `path`, `description`, `api_group`, `service_name`, `method`, `is_required`, `source_type`, `source_id`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '/core_api/admin/user/login', 'apiDesc.userLogin', 'user', 'Core', 'POST', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000002', '/core_api/admin/user/register', 'apiDesc.userRegister', 'user', 'Core', 'POST', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000003', '/core_api/admin/user/create', 'apiDesc.createUser', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000004', '/core_api/admin/user/update', 'apiDesc.updateUser', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000005', '/core_api/admin/user/change_password', 'apiDesc.userChangePassword', 'user', 'Core', 'POST', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000006', '/core_api/admin/user/info', 'apiDesc.userInfo', 'user', 'Core', 'GET', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000007', '/core_api/admin/user/list', 'apiDesc.userList', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000008', '/core_api/admin/user/delete', 'apiDesc.deleteUser', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000009', '/core_api/admin/user/perm', 'apiDesc.userPermissions', 'user', 'Core', 'GET', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000010', '/core_api/admin/user/profile', 'apiDesc.userProfile', 'user', 'Core', 'GET', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000011', '/core_api/admin/user/logout', 'apiDesc.logout', 'user', 'Core', 'GET', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000012', '/core_api/admin/user', 'apiDesc.getUserById', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000013', '/core_api/admin/user/refresh_token', 'apiDesc.refreshToken', 'user', 'Core', 'GET', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000014', '/core_api/admin/user/access_token', 'apiDesc.accessToken', 'user', 'Core', 'GET', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000015', '/core_api/admin/user/create', 'apiDesc.createUser', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000016', '/core_api/admin/user/update', 'apiDesc.updateUser', 'user', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000017', '/core_api/admin/role/delete', 'apiDesc.deleteRole', 'role', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000018', '/core_api/admin/role/list', 'apiDesc.roleList', 'role', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000019', '/core_api/admin/role', 'apiDesc.getRoleById', 'role', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000020', '/core_api/admin/menu/create', 'apiDesc.createMenu', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000021', '/core_api/admin/menu/update', 'apiDesc.updateMenu', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000022', '/core_api/admin/menu/delete', 'apiDesc.deleteMenu', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000023', '/core_api/admin/menu/list', 'apiDesc.menuList', 'menu', 'Core', 'GET', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000024', '/core_api/admin/menu/role/list', 'apiDesc.menuRoleList', 'authority', 'Core', 'GET', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000025', '/core_api/admin/menu_param/create', 'apiDesc.createMenuParam', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000026', '/core_api/admin/menu_param/update', 'apiDesc.updateMenuParam', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000027', '/core_api/admin/menu_param/list', 'apiDesc.menuParamListByMenuId', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000028', '/core_api/admin/menu_param/delete', 'apiDesc.deleteMenuParam', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000029', '/core_api/admin/menu_param', 'apiDesc.getMenuParamById', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000030', '/core_api/admin/menu', 'apiDesc.getMenuById', 'menu', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000031', '/core_api/admin/captcha', 'apiDesc.captcha', 'captcha', 'Core', 'GET', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000032', '/core_api/admin/authority/api/create_or_update', 'apiDesc.createOrUpdateApiAuthority', 'authority', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000033', '/core_api/admin/authority/api/role', 'apiDesc.APIAuthorityOfRole', 'authority', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000034', '/core_api/admin/authority/menu/create_or_update', 'apiDesc.createOrUpdateMenuAuthority', 'authority', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000035', '/core_api/admin/authority/menu/role', 'apiDesc.menuAuthorityOfRole', 'authority', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000036', '/core_api/admin/api/create', 'apiDesc.createApi', 'api', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000037', '/core_api/admin/api/update', 'apiDesc.updateApi', 'api', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000038', '/core_api/admin/api/delete', 'apiDesc.deleteAPI', 'api', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000039', '/core_api/admin/api/list', 'apiDesc.APIList', 'api', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000040', '/core_api/admin/api', 'apiDesc.getApiById', 'api', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000041', '/core_api/admin/oauth_provider/create', 'apiDesc.createProvider', 'oauth', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000042', '/core_api/admin/oauth_provider/update', 'apiDesc.updateProvider', 'oauth', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000043', '/core_api/admin/oauth_provider/delete', 'apiDesc.deleteProvider', 'oauth', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000044', '/core_api/admin/oauth_provider/list', 'apiDesc.getProviderList', 'oauth', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000045', '/core_api/tenant/oauth/login', 'apiDesc.oauthLogin', 'oauth', 'Core', 'POST', 1, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000046', '/core_api/admin/oauth_provider', 'apiDesc.getProviderById', 'oauth', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000047', '/core_api/tenant/token/create', 'apiDesc.createToken', 'token', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000048', '/core_api/tenant/token/update', 'apiDesc.updateToken', 'token', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000049', '/core_api/admin/token/delete', 'apiDesc.deleteToken', 'token', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000050', '/core_api/admin/token/list', 'apiDesc.getTokenList', 'token', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000051', '/core_api/tenant/token/logout', 'apiDesc.forceLoggingOut', 'token', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
  ('00000000-0000-0000-0000-000000000052', '/core_api/tenant/token', 'apiDesc.getTokenById', 'token', 'Core', 'POST', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL);
"

pub const core_app = r"
REPLACE INTO `vcore`.`core_application` (`id`, `project_id`, `name`, `logo`, `homepage_path`, `description`, `is_multi_tenant`, `max_subscribers`, `max_tenant_subscribes`, `subscribe_mode`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'WMS', '/logo', '/dashboard', 'WMS_ADMIN', 0, 0, 1, 1, 1, NULL, '2025-11-03 10:34:37', NULL, '2025-11-03 10:34:42', 0, NULL);
"

pub const core_app_client = r"
REPLACE INTO `vcore`.`core_app_client` (`id`, `project_id`, `application_id`, `name`, `client_type`, `secret`, `redirect_url`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'APP', 0, 'jsalkfjlsjflsjldlsadkls', '/home', 1, NULL, '2025-11-03 10:36:16', NULL, '2025-11-03 10:36:14', 0, NULL),
('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '小程序', 0, 'jsalkfjlsjflsjldlsadkl2', '/home', 1, NULL, '2025-11-03 10:36:16', NULL, '2025-11-03 10:36:14', 0, NULL);
"

pub const core_connector = r"
REPLACE INTO `vcore`.`core_connector` (`id`, `name`, `logo`, `provider`, `type`, `config`, `description`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', 'Github', '/github', 'Github', 0, '{}', 'Github', 0, NULL, '2025-11-04 10:47:14', NULL, '2025-11-04 10:47:16', 0, NULL);
"

pub const core_menu = r"
REPLACE INTO `vcore`.`core_menu` (`id`, `parent_id`, `menu_level`, `menu_type`, `path`, `name`, `redirect`, `component`, `disabled`, `service_name`, `permission`, `title`, `icon`, `hide_menu`, `hide_breadcrumb`, `ignore_keep_alive`, `hide_tab`, `frame_src`, `carry_param`, `hide_children_in_menu`, `affix`, `dynamic_level`, `real_path`, `sort`, `source_type`, `source_id`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 1, 1, '/dashboard', 'Dashboard', '', '/dashboard/workbench/index', 0, 'Core', NULL, 'route.dashboard', 'ant-design:home-outlined', 0, 0, 0, 0, '', 0, 0, 0, 20, '', 0, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL),
('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 2, 0, '/system', 'SystemManagement', '', 'LAYOUT', 0, 'Core', NULL, 'route.systemManagementTitle', 'ant-design:tool-outlined', 0, 0, 0, 0, '', 0, 0, 0, 20, '', 999, 'tenant', '00000000-0000-0000-0000-000000000000', NULL, '2024-11-18 00:54:02', NULL, '2024-11-18 00:54:02', 0, NULL);
"

pub const core_project = r"
REPLACE INTO `vcore`.`core_project` (`id`, `name`, `display_name`, `logo`, `description`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', 'IAM', 'IAM', '/logo', 'IAM', NULL, '2025-11-04 10:14:54', NULL, '2025-11-04 10:14:58', 0, NULL);
"

pub const core_role = r"
REPLACE INTO `vcore`.`core_role` (`id`, `tenant_id`, `name`, `default_router`, `remark`, `sort`, `status`, `type`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owser', '/dashboard', NULL, 0, 0, 'tenant', NULL, '2025-11-04 10:17:47', NULL, '2025-11-04 10:17:49', 0, NULL);
"

pub const core_role_api = r"
REPLACE INTO `core_role_api` (`role_id`, `api_id`,`source_type`,`source_id`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001','Tenant','00000000-0000-0000-0000-000000000001');
"

pub const core_role_menu = r"
REPLACE INTO `core_role_menu` (`role_id`, `menu_id`,`source_type`,`source_id`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001','Tenant', '00000000-0000-0000-0000-000000000001');
"

pub const core_role_tenant_member = r"
REPLACE INTO `core_role_tenant_member` (`tenant_id`, `member_id`, `role_id`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001');
"

pub const core_tenant = r"
REPLACE INTO `vcore`.`core_tenant` (`id`, `logo_url`, `name`, `type`, `slug`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '/logo_url', '我的团队', '0', 'tenant', 0, NULL, '2025-11-04 10:26:46', NULL, '2025-11-04 10:26:44', 0, NULL);
"

pub const core_tenant_member = r"
REPLACE INTO `vcore`.`core_tenant_member` (`tenant_id`, `member_id`, `is_owner`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 1, NULL, '2025-11-04 10:28:45', NULL, '2025-11-04 10:28:48', 0, NULL);
"

pub const core_tenant_subapp = r"
REPLACE INTO `vcore`.`core_tenant_subapp` (`id`, `tenant_id`, `application_id`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 0, NULL, '2025-11-04 10:29:45', NULL, '2025-11-04 10:29:48', 0, NULL);
"

pub const core_token = r"
REPLACE INTO `vcore`.`core_token` (`id`, `user_id`, `username`, `token`, `source`, `expired_at`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'admin', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6IiJ9.eyJpc3MiOiJ2cHJvZC13b3Jrc3Bhc2UiLCJzdWIiOiIwMTk2YjczNi1mODA3LTczZjAtODczMS03YTA4YzBlZDc1ZWEiLCJhdWQiOlsiYXBpLXNlcnZpY2UiLCJ3ZWJhcHAiXSwibmJmIjoxNzQ4OTQ1Mjc4LCJleHAiOjIwMDgxNDUyNzgsImlhdCI6MTc0ODk0NTI3OCwianRpIjoiNTkwN2FmM2EtM2Y1YS00MDg2LWFhZWItNjhlY2EyODNkOGQyIiwicm9sZXMiOlsiYWRtaW4iLCJlZGl0b3IiXSwidGVhbV9pZCI6IiIsImFwcF9pZCI6IiIsInBvcnRhbF9pZCI6IiIsImNsaWVudF9pcCI6IjE5Mi4xNjguMS4xMDAiLCJkZXZpY2VfaWQiOiJkZXZpY2UteHl6In0.6vJKEZi-oKmX0LPx63Y80Fph6MJZnywK2Q98Ioq4clA', 'Core_user', '2035-12-31 00:54:47', 0, NULL, '2025-12-31 00:54:47', NULL, '2025-12-31 00:54:47', 0, NULL);
"

pub const core_user = r"
REPLACE INTO `core_user` (`id`, `username`, `password`, `password_salt`, `nickname`, `bio`, `description`, `home_path`, `phone`, `email`, `avatar`, `status`, `language`, `shiqu`, `id_card_type`, `id_card`, `tag`, `region`, `gender`, `birthday`, `education`, `score`, `ranking`, `is_online`, `signup_application`, `hash`, `pre_hash`, `created_ip`, `last_signin_time`, `last_signin_ip`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES ('00000000-0000-0000-0000-000000000001', 'tenant', '$2a$10${E0E6oRFnroxrPrDkRwA5s.AEiHNThGMdcA4HwPC1CBmP38tCn3De2}', '164564646546156163', 'Tenant', NULL, NULL, '/dashboard', NULL, NULL, NULL, 0, 'English', 'UTC +00:00', 0, NULL, NULL, NULL, 0, NULL, 0, 0, 0, 0, NULL, NULL, NULL, '10.243.0.1', '2025-11-04 10:40:42', '10.243.0.1', NULL, '2025-11-04 10:40:11', NULL, '2025-11-04 10:40:13', 0, NULL);
"

pub const core_user_connector = r"
REPLACE INTO `vcore`.`core_user_connector` (`id`, `user_id`, `connector_id`, `provider_user_id`, `profile`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '{}', NULL, '2025-11-04 10:42:48', NULL, '2025-11-04 10:42:50', 0, NULL);
"
