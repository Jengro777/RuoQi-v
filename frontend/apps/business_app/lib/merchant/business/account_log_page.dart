import 'package:flutter/material.dart';

/// 账号日志（APP 终端用户）——业务静态页。
class AccountLogPage extends StatelessWidget {
  const AccountLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logs = [
      ('登录', '账号在北京登录', '2024-08-12 10:04', Icons.login),
      ('修改密码', '登录密码已修改', '2024-08-11 09:30', Icons.password),
      ('绑定手机', '手机号 138****9521 已绑定', '2024-08-05 18:22', Icons.phone_iphone),
      ('绑定邮箱', '邮箱 n***@email.com 已绑定', '2024-07-28 14:10', Icons.mail_outline),
      ('登出', '账号在 MacBook Pro 登出', '2024-07-28 12:00', Icons.logout),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('账号日志')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: logs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final log = logs[i];
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(log.$4, color: colorScheme.onPrimaryContainer),
              ),
              title: Text(log.$1),
              subtitle: Text(log.$2),
              trailing: Text(
                log.$3,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}
