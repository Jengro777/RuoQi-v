import 'package:flutter/material.dart';

import 'account_security_page/index.dart';
import 'localization_page/index.dart';
import 'mfa_page/index.dart';
import 'profile_page/index.dart';
import 'theme_page/index.dart';

/// 个人中心页面构建上下文：页内跳转 + 应用外观设置（主题页使用）。
class PersonalNavContext {
  const PersonalNavContext({
    required this.onOpenPage,
    this.themeMode,
    this.onThemeModeChanged,
    this.accent,
    this.onAccentChanged,
  });

  /// 切换到个人中心下的其它页面（如「账号安全」）。
  final ValueChanged<String> onOpenPage;

  /// 当前背景模式 / 切换回调（个人中心 → 主题）。
  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  /// 当前强调色 / 切换回调（个人中心 → 主题）。
  final Color? accent;
  final ValueChanged<Color>? onAccentChanged;
}

/// 个人中心导航项：菜单文案 + 正文 Builder。
///
/// 正文由外壳注入 [PersonalNavContext]，页面内的「账号安全 / 多因素认证 / 本地化」
/// 入口即可直接切换菜单选中项，而不是再叠一层弹层。
class PersonalNavItem {
  const PersonalNavItem(this.label, this.builder);

  final String label;
  final Widget Function(PersonalNavContext context) builder;
}

/// 个人中心页面顺序（个人资料 / 账号安全 / 多因素认证 / 本地化 / 主题）。
const personalNavItems = <PersonalNavItem>[
  PersonalNavItem('个人资料', _buildProfile),
  PersonalNavItem('账号安全', _buildAccountSecurity),
  PersonalNavItem('多因素认证', _buildMfa),
  PersonalNavItem('本地化', _buildLocalization),
  PersonalNavItem('主题', _buildTheme),
];

Widget _buildProfile(PersonalNavContext context) =>
    ProfileBody(onOpenPage: context.onOpenPage);

Widget _buildAccountSecurity(PersonalNavContext context) =>
    AccountSecurityBody(onOpenPage: context.onOpenPage);

Widget _buildMfa(PersonalNavContext _) => const MfaBody();

Widget _buildLocalization(PersonalNavContext _) => const LocalizationBody();

Widget _buildTheme(PersonalNavContext context) => ThemeBody(
  themeMode: context.themeMode,
  onThemeModeChanged: context.onThemeModeChanged,
  accent: context.accent,
  onAccentChanged: context.onAccentChanged,
);
