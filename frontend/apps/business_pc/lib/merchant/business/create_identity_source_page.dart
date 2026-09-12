import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 创建身份源。
class CreateIdentitySourcePage extends StatelessWidget {
  const CreateIdentitySourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('创建身份源')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          const TextField(decoration: InputDecoration(labelText: '身份源名称')),
          const SizedBox(height: RuQiSpacing.md),
          const TextField(decoration: InputDecoration(labelText: '协议')),
          const SizedBox(height: RuQiSpacing.md),
          const TextField(decoration: InputDecoration(labelText: 'Client ID')),
          const SizedBox(height: RuQiSpacing.md),
          const TextField(
            decoration: InputDecoration(labelText: 'Client Secret'),
            obscureText: true,
          ),
          const SizedBox(height: RuQiSpacing.lg),
          FilledButton(
            onPressed: () {},
            style: RuQiButtonStyles.primary(context),
            child: const Text('创建'),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Text(
            '连接后将自动同步身份源内的用户与组织。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
