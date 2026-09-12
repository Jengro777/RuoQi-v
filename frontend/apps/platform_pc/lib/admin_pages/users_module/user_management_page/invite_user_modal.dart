import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'user_common.dart';

/// 打开邀请用户面板。
Future<void> showInviteUserPanel(BuildContext context) async {
  final result = await showSystemSettingsPanel<({String name, String email})>(
    context,
    title: '新用户',
    child: const InviteUserForm(),
  );
  if (result != null && context.mounted) {
    await showInviteTokenResultPanel(
      context,
      name: result.name,
      email: result.email,
    );
  }
}

/// 打开邀请结果面板（邀请令牌-邮件 方案）。
Future<void> showInviteTokenResultPanel(
  BuildContext context, {
  required String name,
  required String email,
}) {
  return showSystemSettingsPanel(
    context,
    title: '邀请用户',
    child: InviteTokenResultPanel(name: name, email: email),
  );
}

/// 邀请用户表单：名字 / 姓氏 / 电子邮件 / 角色。
class InviteUserForm extends StatefulWidget {
  const InviteUserForm({super.key});

  @override
  State<InviteUserForm> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<InviteUserForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController(text: 'nicetoseeyou@email.com');
  String _role = '普通用户';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstName.text.trim().isEmpty
        ? '名字'
        : _firstName.text.trim();
    final lastName = _lastName.text.trim().isEmpty
        ? '姓氏'
        : _lastName.text.trim();
    final email = _email.text.trim().isEmpty
        ? 'email@@email.com'
        : _email.text.trim();
    Navigator.of(context).pop((name: '$firstName $lastName', email: email));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleOptions = [
      for (final role in roleGroups) role.name,
      if (!roleGroups.any((r) => r.name == '自定义角色')) '自定义角色',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstName,
                        decoration: const InputDecoration(
                          labelText: '名字',
                          hintText: '名*',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lastName,
                        decoration: const InputDecoration(
                          labelText: '姓氏',
                          hintText: '姓*',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '电子邮件',
                    hintText: '电子邮件*',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Text(
                  '角色',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.xs),
                Wrap(
                  spacing: RuQiSpacing.xs,
                  runSpacing: RuQiSpacing.xs,
                  children: [
                    for (final option in roleOptions)
                      ChoiceChip(
                        label: Text(option),
                        selected: _role == option,
                        onSelected: (_) => setState(() => _role = option),
                      ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Text(
                  '邀请后系统会向该邮箱发送邀请邮件；如未配置邮件服务，'
                  '将改用邀请令牌方式告知登录信息。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '邀请', onConfirm: _submit),
      ],
    );
  }
}

/// 邀请结果：已完成添加 + 邀请令牌（可复制）。
class InviteTokenResultPanel extends StatelessWidget {
  const InviteTokenResultPanel({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  static const _tokenUrl =
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
            '$name 已经被添加',
            style: zh(
              theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '已成功发送电子邮件邀请，您也可以复制我们生成的 邀请令牌 分享给 '
            '$email ，让其使用邀请令牌设置密码后登录。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          UserCopyRow(label: '邀请令牌', value: _tokenUrl),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '如果你想能够发送电子邮件邀请，需要先设置 Email 服务（设置 → 电子邮件）。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
