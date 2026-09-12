import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 身份源列表。
class IdentitySourcePage extends StatelessWidget {
  const IdentitySourcePage({super.key});

  static const _sources = [
    ('企业微信', 'OIDC', '已连接'),
    ('钉钉', 'OIDC', '已连接'),
    ('飞书', 'OAuth2', '未连接'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('身份源')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          for (final (name, protocol, status) in _sources)
            Card(
              margin: const EdgeInsets.only(bottom: RuQiSpacing.sm),
              child: ListTile(
                leading: Icon(
                  Icons.fingerprint,
                  color: theme.colorScheme.primary,
                ),
                title: Text(name),
                subtitle: Text(protocol),
                trailing: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status == '已连接'
                        ? (ext?.success ?? theme.colorScheme.primary)
                        : (ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('创建身份源'),
      ),
    );
  }
}
