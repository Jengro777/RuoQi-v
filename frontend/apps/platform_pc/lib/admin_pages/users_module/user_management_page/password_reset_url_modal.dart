import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';

import 'user_common.dart';

/// 打开「重置密码（密码重置URL方案）」结果面板。
Future<void> showPasswordResetUrlPanel(BuildContext context, UserAccount user) {
  return showSystemSettingsPanel(
    context,
    title: '重置密码',
    child: PasswordResetUrlPanel(user: user),
  );
}

/// 密码重置 URL 结果：完成 + 可复制链接。
class PasswordResetUrlPanel extends StatelessWidget {
  const PasswordResetUrlPanel({super.key, required this.user});

  final UserAccount user;

  static const _resetUrl =
      'https://xxx/dashboard/#/signup/1e0a91b9-7319-4241-9114-c5569413252f';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: ext?.success ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '${user.displayName} 的账户已生成密码重置URL',
            style: zh(
              theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '这是最新的密码重置URL，请复制发送。密码重置成功后此链接将失效。'
            '（旧的密码重置链接已失效）',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          UserCopyRow(label: '密码重置URL', value: _resetUrl),
        ],
      ),
    );
  }
}
