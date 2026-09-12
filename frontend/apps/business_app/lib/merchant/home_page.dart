import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'business/account_frozen_dialog.dart';
import 'business/account_links_page.dart';
import 'business/account_log_page.dart';
import 'business/account_security_page.dart';
import 'business/agreement_dialog.dart';
import 'business/device_list_page.dart';
import 'business/edit_profile_page.dart';
import 'business/forgot_password_page.dart';
import 'business/login_methods_page.dart';
import 'business/phone_not_registered_dialog.dart';
import 'business/profile_page.dart';
import 'business/register_page.dart';
import 'business/set_password_page.dart';
import 'business/sms_login_page.dart';
import 'business/third_party_login_page.dart';
import 'prototype_registry.dart';
import 'prototype_viewer.dart';

/// 商户端（App）原型首页：登录 / 注册 / 个人中心等 IDM 租户业务页面。
class MerchantHomePage extends StatelessWidget {
  const MerchantHomePage({super.key, this.embedded = false});

  /// 嵌入业务工作台弹窗时去掉自带 AppBar（弹窗顶部已有控制台导航栏）。
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PrototypeEntry>>{};
    for (final e in prototypePages) {
      grouped.putIfAbsent(e.path.split('/').first, () => []).add(e);
    }
    final keys = grouped.keys.toList()..sort();
    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('业务静态页（语义化重构）', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _header(context, '登录'),
              _entry(
                context,
                '登录方式选择',
                '密码 / 验证码 / 第三方',
                Icons.login,
                const LoginMethodsPage(),
              ),
              _divider(),
              _entry(
                context,
                '手机验证码登录',
                '登录表单',
                Icons.phone_iphone,
                const SmsLoginPage(),
              ),
              _divider(),
              _header(context, '注册'),
              _entry(
                context,
                '手机号注册',
                '注册表单 + 协议勾选',
                Icons.app_registration,
                const RegisterPage(),
              ),
              _divider(),
              _entry(
                context,
                '设置登录密码',
                '注册流程设置密码',
                Icons.password,
                const SetPasswordPage(),
              ),
              _divider(),
              _header(context, '找回密码'),
              _entry(
                context,
                '找回密码',
                '查找账号 → 验证 → 重置',
                Icons.lock_reset,
                const ForgotPasswordPage(),
              ),
              _divider(),
              _header(context, '个人中心'),
              _entry(
                context,
                '用户个人中心',
                '我的 + 账号与安全',
                Icons.person_outline,
                const ProfilePage(),
              ),
              _divider(),
              _entry(
                context,
                '账号安全',
                '密码 / 手机 / 邮箱 / 关联',
                Icons.security_outlined,
                const AccountSecurityPage(),
              ),
              _divider(),
              _entry(
                context,
                '个人资料编辑',
                '昵称 / 性别 / 头像',
                Icons.badge_outlined,
                const EditProfilePage(),
              ),
              _divider(),
              _entry(
                context,
                '账号关联',
                '微信 / Apple / Google',
                Icons.link,
                const AccountLinksPage(),
              ),
              _divider(),
              _entry(
                context,
                '设备管理',
                '登录设备列表',
                Icons.devices_other,
                const DeviceListPage(),
              ),
              _divider(),
              _entry(
                context,
                '账号日志',
                '登录与安全记录',
                Icons.receipt_long_outlined,
                const AccountLogPage(),
              ),
              _divider(),
              _header(context, '登录提示与弹窗'),
              _entry(
                context,
                '第三方登录授权',
                '关联/授权切换',
                Icons.link,
                const ThirdPartyLoginPage(),
              ),
              _divider(),
              _dialogEntry(
                context,
                '账号冻结弹窗',
                '冻结提示 + 联系客服',
                Icons.block,
                AccountFrozenDialog.show,
              ),
              _divider(),
              _dialogEntry(
                context,
                '手机号未注册提示',
                '未注册弹窗',
                Icons.phone_disabled,
                PhoneNotRegisteredDialog.show,
              ),
              _divider(),
              _dialogEntry(
                context,
                '协议勾选弹窗',
                '隐私政策 + 用户服务协议',
                Icons.description_outlined,
                AgreementDialog.show,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '原型页面（像素级复刻，共 ${prototypePages.length} 页）',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '共 ${grouped.length} 个模块、${prototypePages.length} 个页面（来自摹客 RP 原型，自动转换）',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        for (final key in keys) ...[
          ExpansionTile(
            title: Text(key),
            tilePadding: EdgeInsets.zero,
            children: [
              for (final e in grouped[key]!)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.description_outlined, size: 18),
                  title: Text(e.title),
                  subtitle: Text(
                    e.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrototypeViewer(entry: e),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );

    if (embedded) {
      return Material(color: Theme.of(context).colorScheme.surface, child: body);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RuoQi 商户(App) — IDM 租户业务页面'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: AppBadge(appName: 'merchant_app', version: '1.0.0'),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _entry(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56);

  Widget _dialogEntry(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Future<void> Function(BuildContext) show,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => show(context),
    );
  }

  Widget _header(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
