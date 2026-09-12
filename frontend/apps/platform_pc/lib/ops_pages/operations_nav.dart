import 'package:flutter/material.dart';

import 'api_auth_module/api_token_page/index.dart';
import 'profile_module/account_security_page/index.dart';
import 'profile_module/localization_page/index.dart';
import 'profile_module/mfa_page/index.dart';
import 'profile_module/profile_page/index.dart';
import 'project_module/project_list_page/index.dart';
import 'project_module/project_settings_page/index.dart';
import 'project_module/subscription_billing_page/index.dart';
import 'project_module/subscription_cancel_audit_page/index.dart';
import 'project_module/subscription_change_audit_page/index.dart';
import 'project_module/subscription_open_audit_page/index.dart';
import 'team_space_module/team_settings_page/index.dart';
import 'team_space_module/team_space_page/index.dart';
import 'tenant_module/member_manage_page/index.dart';
import 'tenant_module/tenant_audit_page/index.dart';
import 'tenant_module/tenant_list_page/index.dart';
import 'tenant_module/tenant_settings_page/index.dart';

/// 运营后台导航项：标题 + 真实业务页正文 Builder。
class OperationsNavItem {
  const OperationsNavItem(this.label, this.builder);

  final String label;
  final WidgetBuilder builder;
}

/// 运营后台导航板块。
class OperationsNavSection {
  const OperationsNavSection(this.label, this.items);

  final String label;
  final List<OperationsNavItem> items;
}

/// 板块顺序与 运营后台 一致（租户 / 团队空间 / 项目 / API授权 / 个人中心）。
const operationsNavSections = [
  OperationsNavSection('租户', [
    OperationsNavItem('租户列表', _build1),
    OperationsNavItem('成员管理', _build2),
    OperationsNavItem('开户审核', _build3),
    OperationsNavItem('租户设置', _build4),
  ]),
  OperationsNavSection('团队空间', [
    OperationsNavItem('团队空间', _build5),
    OperationsNavItem('团队设置', _build6),
  ]),
  OperationsNavSection('项目', [
    OperationsNavItem('项目列表', _build7),
    OperationsNavItem('项目设置', _build8),
    OperationsNavItem('订阅计费', _build9),
    OperationsNavItem('开通审核', _build10),
    OperationsNavItem('变更审核', _build11),
    OperationsNavItem('退订审核', _build12),
  ]),
  OperationsNavSection('API授权', [
    OperationsNavItem('API令牌', _build13),
  ]),
  OperationsNavSection('个人中心', [
    OperationsNavItem('个人资料', _build14),
    OperationsNavItem('账号安全', _build15),
    OperationsNavItem('多因素认证', _build16),
    OperationsNavItem('本地化', _build17),
  ]),
];

Widget _build1(BuildContext _) => const TenantListBody();
Widget _build2(BuildContext _) => const MemberManageBody();
Widget _build3(BuildContext _) => const TenantAuditBody();
Widget _build4(BuildContext _) => const TenantSettingsBody();
Widget _build5(BuildContext _) => const TeamSpaceBody();
Widget _build6(BuildContext _) => const TeamSettingsBody();
Widget _build7(BuildContext _) => const ProjectListBody();
Widget _build8(BuildContext _) => const ProjectSettingsBody();
Widget _build9(BuildContext _) => const SubscriptionBillingBody();
Widget _build10(BuildContext _) => const SubscriptionOpenAuditBody();
Widget _build11(BuildContext _) => const SubscriptionChangeAuditBody();
Widget _build12(BuildContext _) => const SubscriptionCancelAuditBody();
Widget _build13(BuildContext _) => const ApiTokenBody();
Widget _build14(BuildContext _) => const ProfileBody();
Widget _build15(BuildContext _) => const AccountSecurityBody();
Widget _build16(BuildContext _) => const MfaBody();
Widget _build17(BuildContext _) => const LocalizationBody();
