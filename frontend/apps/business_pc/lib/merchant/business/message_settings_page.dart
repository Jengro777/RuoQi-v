import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 消息设置。
class MessageSettingsPage extends StatelessWidget {
  const MessageSettingsPage({super.key});

  static const _channels = [
    ('站内信', true),
    ('邮件通知', true),
    ('短信通知', false),
    ('Webhook 推送', true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('消息设置')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          for (final (name, enabled) in _channels)
            Card(
              margin: const EdgeInsets.only(bottom: RuQiSpacing.sm),
              child: SwitchListTile(
                title: Text(name),
                value: enabled,
                onChanged: (_) {},
              ),
            ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '变更会即时生效，无需重新部署。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
