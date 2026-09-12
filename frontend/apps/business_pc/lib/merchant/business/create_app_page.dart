import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 创建自建应用。
class CreateAppPage extends StatelessWidget {
  const CreateAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('创建应用')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          const TextField(decoration: InputDecoration(labelText: '应用名称')),
          const SizedBox(height: RuQiSpacing.md),
          const TextField(decoration: InputDecoration(labelText: '应用类型')),
          const SizedBox(height: RuQiSpacing.md),
          const TextField(decoration: InputDecoration(labelText: '描述')),
          const SizedBox(height: RuQiSpacing.lg),
          FilledButton(
            onPressed: () {},
            style: RuQiButtonStyles.primary(context),
            child: const Text('创建'),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Text(
            '创建后可在应用配置中获取 AppID 与 AppSecret。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
