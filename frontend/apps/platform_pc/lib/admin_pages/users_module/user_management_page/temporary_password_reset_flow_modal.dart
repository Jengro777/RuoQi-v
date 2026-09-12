import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';

import 'user_confirm_dialog.dart';

/// 打开「重置密码（临时密码方案）」确认与结果。
Future<void> showTemporaryPasswordResetFlow(
  BuildContext context,
  UserAccount user,
) async {
  final confirmed = await showUserConfirmDialog(
    context,
    title: '重置密码',
    content: Text('你确定要重置 ${user.account} 的密码吗？重置后旧密码立即失效。'),
    confirmLabel: '重置密码',
  );
  if (confirmed && context.mounted) {
    await showPasswordResetSuccessPanel(context, user);
  }
}

/// 打开密码重置成功面板（临时密码方案）。
Future<void> showPasswordResetSuccessPanel(
  BuildContext context,
  UserAccount user,
) {
  return showSystemSettingsPanel(
    context,
    title: '重置密码',
    child: PasswordResetSuccessPanel(user: user),
  );
}

/// 密码重置成功：临时密码（可显示 / 隐藏）。
class PasswordResetSuccessPanel extends StatelessWidget {
  const PasswordResetSuccessPanel({super.key, required this.user});

  final UserAccount user;

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
            '${user.displayName} 的密码已被重置',
            style: zh(
              theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '这是系统提供的用于登录的临时密码，登录成功后请修改密码。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          const _TemporaryPasswordRow(),
        ],
      ),
    );
  }
}

/// 临时密码展示行：显示 / 隐藏 + 复制。
class _TemporaryPasswordRow extends StatefulWidget {
  const _TemporaryPasswordRow();

  @override
  State<_TemporaryPasswordRow> createState() => _TemporaryPasswordRowState();
}

class _TemporaryPasswordRowState extends State<_TemporaryPasswordRow> {
  static const _password = 'Cw3#xK9pLm';
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '临时密码',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: RuQiSpacing.md),
        Expanded(
          child: Text(
            _visible ? _password : '••••••••••',
            style: RuQiTextStyles.mono.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _visible = !_visible),
          style: RuQiButtonStyles.tertiary(context),
          child: Text(_visible ? '隐藏' : '显示'),
        ),
      ],
    );
  }
}
