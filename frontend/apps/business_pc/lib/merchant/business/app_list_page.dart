import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'app_config_page.dart';

/// 自建应用列表。
class AppListPage extends StatelessWidget {
  const AppListPage({super.key});

  static const _apps = [
    ('一账通门户', 'web', '已启用'),
    ('商户后台', 'web', '已启用'),
    ('客服工作台', 'mobile', '停用'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('自建应用')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          for (final (name, kind, status) in _apps)
            Card(
              margin: const EdgeInsets.only(bottom: RuQiSpacing.sm),
              child: ListTile(
                leading: Icon(
                  kind == 'web' ? Icons.language : Icons.phone_iphone,
                  color: theme.colorScheme.primary,
                ),
                title: Text(name),
                subtitle: Text(kind),
                trailing: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status == '已启用'
                        ? (ext?.success ?? theme.colorScheme.primary)
                        : (ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppConfigPage()),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('创建应用'),
      ),
    );
  }
}
