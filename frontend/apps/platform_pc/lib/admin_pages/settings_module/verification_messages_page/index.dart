import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'verification_message_models.dart';
import 'verification_message_settings_modal.dart';

/// 设置-验证消息 业务正文（替换静态原型复刻页）。
///
/// 每个验证消息项提供可用的「设置」按钮，打开对应设置弹窗。
class VerificationMessagesBody extends StatelessWidget {
  const VerificationMessagesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          '验证消息',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '配置各类验证消息的通知模板与发送渠道。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 2 : 1;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * RuQiSpacing.md) /
                columns;
            return Wrap(
              spacing: RuQiSpacing.md,
              runSpacing: RuQiSpacing.md,
              children: [
                for (final item in verificationMessageItems)
                  SizedBox(
                    width: cardWidth,
                    child: _MessageCard(item: item),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.item});

  final VerificationMessageItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: RuQiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RuQiSpacing.sm),
            OutlinedButton(
              onPressed: () =>
                  showVerificationMessageSettingsDialog(context, item),
              style: RuQiButtonStyles.secondary(context),
              child: const Text('设置'),
            ),
          ],
        ),
      ),
    );
  }
}
