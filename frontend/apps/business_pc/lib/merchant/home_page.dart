import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'business/app_list_page.dart';
import 'business/identity_source_page.dart';
import 'business/import_page.dart';
import 'business/message_settings_page.dart';

/// 商户端（PC）业务入口页：IDM 租户业务页面。
class MerchantHomePage extends StatelessWidget {
  const MerchantHomePage({super.key, this.embedded = false});

  /// 嵌入业务工作台弹窗时使用：弹窗顶部已有控制台导航栏，
  /// 因此去掉页面自带的 AppBar，只保留正文。
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: ListView(
          padding: const EdgeInsets.all(RuQiSpacing.lg),
          children: [
            Text(
              '业务静态页（语义化重构）',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            _entry(
              context,
              icon: Icons.apps,
              title: '自建应用',
              subtitle: '应用列表 / 应用配置',
              page: const AppListPage(),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _entry(
              context,
              icon: Icons.fingerprint,
              title: '身份源',
              subtitle: '身份源列表 / 创建身份源',
              page: const IdentitySourcePage(),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _entry(
              context,
              icon: Icons.cloud_upload_outlined,
              title: '导入',
              subtitle: '批量导入用户与组织',
              page: const ImportPage(),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            _entry(
              context,
              icon: Icons.notifications_outlined,
              title: '消息设置',
              subtitle: '通知渠道与模板',
              page: const MessageSettingsPage(),
            ),
          ],
        ),
      ),
    );

    if (embedded) {
      return Material(color: theme.colorScheme.surface, child: body);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RuoQi 商户(PC) — IDM 租户业务页面'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: AppBadge(appName: 'merchant_pc', version: '1.0.0'),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _entry(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RuQiSpacing.lg,
          vertical: RuQiSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
