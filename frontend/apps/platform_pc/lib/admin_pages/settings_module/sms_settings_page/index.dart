import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'aliyun_sms_settings_modal.dart';

/// 设置-短信 业务正文（替换静态原型复刻页）。
///
/// 「阿里云短信」卡片提供可用的「设置」按钮，打开阿里云短信配置弹窗。
class SmsSettingsBody extends StatelessWidget {
  const SmsSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          '短信',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '配置短信服务商与发送渠道。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        _ProviderCard(
          title: '阿里云短信',
          description:
              '阿里云短信服务为用户提供一种通信服务能力，'
              '支持快速发送短信验证码、短信通知等，服务范围覆盖全球。',
          icon: Icons.cloud_outlined,
          onSetting: () => showAliyunSmsSettingsDialog(context),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onSetting,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onSetting;

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
              child: Icon(icon, size: 22, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: RuQiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RuQiSpacing.sm),
            OutlinedButton(
              onPressed: onSetting,
              style: RuQiButtonStyles.secondary(context),
              child: const Text('设置'),
            ),
          ],
        ),
      ),
    );
  }
}
