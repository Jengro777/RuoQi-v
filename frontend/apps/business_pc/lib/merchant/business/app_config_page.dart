import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 应用配置。
class AppConfigPage extends StatelessWidget {
  const AppConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('应用配置')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          const TextField(decoration: InputDecoration(labelText: '应用名称')),
          const SizedBox(height: RuQiSpacing.md),
          const TextField(decoration: InputDecoration(labelText: '回调地址')),
          const SizedBox(height: RuQiSpacing.lg),
          FilledButton(
            onPressed: () {},
            style: RuQiButtonStyles.primary(context),
            child: const Text('保存配置'),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Text(
            '提示：回调地址支持 HTTPS 与 localhost。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
