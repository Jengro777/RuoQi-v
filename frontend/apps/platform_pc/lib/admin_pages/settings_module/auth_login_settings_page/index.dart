import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'google_login_settings_modal.dart';

/// 设置-auth登录 业务正文（替换静态原型复刻页）。
///
/// 「Google账号登录」卡片提供可用的「设置」按钮，打开 Google 登录配置弹窗。
class AuthLoginBody extends StatelessWidget {
  const AuthLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          'auth登录',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '配置第三方账号登录方式。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Card(
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
                    Icons.g_mobiledata,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: RuQiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google账号登录',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '允许拥有现有运营后台账户的用户在当前的用户名和密码的基础上，'
                        '用与他们的电子邮件地址相匹配的谷歌账户登录。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: RuQiSpacing.sm),
                OutlinedButton(
                  onPressed: () => showGoogleLoginSettingsDialog(context),
                  style: RuQiButtonStyles.secondary(context),
                  child: const Text('设置'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
