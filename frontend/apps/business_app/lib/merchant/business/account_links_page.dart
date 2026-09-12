import 'package:flutter/material.dart';

/// 账号关联（APP 终端用户）——业务静态页。
class AccountLinksPage extends StatelessWidget {
  const AccountLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('账号关联')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _tile(context, Icons.wechat, '微信', true, colorScheme),
          _tile(context, Icons.apple, 'Apple ID', false, colorScheme),
          _tile(context, Icons.g_mobiledata, 'Google', false, colorScheme),
          _tile(context, Icons.facebook, 'Facebook', false, colorScheme),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '关联第三方账号后，可使用对应账号快速登录一账通。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    bool bound,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(title),
        trailing: bound
            ? TextButton(onPressed: () {}, child: const Text('解绑'))
            : FilledButton.tonal(onPressed: () {}, child: const Text('绑定')),
      ),
    );
  }
}
