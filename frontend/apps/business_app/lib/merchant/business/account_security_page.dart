import 'package:flutter/material.dart';

/// 账号安全（APP 终端用户）——业务静态页。
///
/// 原型仅提供「账户安全」标题，条目按 IDM 常见安全设置语义补全。
class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('账户安全')),
      body: ListView(
        children: [
          _section(
            context,
            '登录凭证',
            [
              _tile(context, '登录密码', '已设置', Icons.lock_outline, onTap: () {}),
              _tile(context, '手机号', '138****9521', Icons.phone_iphone, onTap: () {}),
              _tile(context, '邮箱', 'n***@email.com', Icons.mail_outline, onTap: () {}),
            ],
          ),
          _section(
            context,
            '账号关联',
            [
              _tile(context, '微信', '未绑定', Icons.wechat, onTap: () {}),
              _tile(context, 'Apple ID', '未绑定', Icons.apple, onTap: () {}),
              _tile(context, 'Google', '未绑定', Icons.g_mobiledata, onTap: () {}),
            ],
          ),
          _section(
            context,
            '安全与记录',
            [
              _tile(context, '设备管理', '2 台设备', Icons.devices_other, onTap: () {}),
              _tile(context, '账号日志', '', Icons.receipt_long_outlined, onTap: () {}),
              _tile(
                context,
                '注销账号',
                '',
                Icons.delete_outline,
                color: colorScheme.error,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          clipBehavior: Clip.antiAlias,
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
