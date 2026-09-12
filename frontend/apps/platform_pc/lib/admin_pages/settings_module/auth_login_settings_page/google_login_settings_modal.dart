import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';

/// 打开 Google 账号登录配置面板（与内容区同尺寸）。
Future<void> showGoogleLoginSettingsDialog(BuildContext context) {
  return showSystemSettingsPanel(
    context,
    title: 'Google账号登录 设置',
    child: const GoogleLoginSettingsForm(),
  );
}

/// Google 账号登录配置表单（参照 设置/auth登录/Google登录 原型）。
class GoogleLoginSettingsForm extends StatefulWidget {
  const GoogleLoginSettingsForm({super.key});

  @override
  State<GoogleLoginSettingsForm> createState() =>
      _GoogleLoginSettingsFormState();
}

class _GoogleLoginSettingsFormState extends State<GoogleLoginSettingsForm> {
  late final TextEditingController _clientId;
  late final TextEditingController _allowedDomain;

  @override
  void initState() {
    super.initState();
    _clientId = TextEditingController(
      text: '{your-client-id}.apps.googleusercontent.com',
    );
    _allowedDomain = TextEditingController(text: 'mycompany.com');
  }

  @override
  void dispose() {
    _clientId.dispose();
    _allowedDomain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _clientId,
            decoration: const InputDecoration(
              labelText: '客户ID',
              helperText: 'Google Cloud Console 中创建的 OAuth 客户端 ID。',
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Text(
            '允许用户登录，如果用户的 Google 帐户电子邮件地址来自：',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.xs),
          TextField(
            controller: _allowedDomain,
            decoration: const InputDecoration(
              labelText: '域名',
              helperText: '多个域名用英文逗号分隔。',
            ),
          ),
          const SizedBox(height: RuQiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.tertiary(context),
                child: const Text('取消'),
              ),
              const SizedBox(width: RuQiSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.primary(context),
                child: const Text('保存并启用'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
