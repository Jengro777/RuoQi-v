import 'package:flutter/material.dart';

import '../mfa_page/index.dart';

/// 账号安全（平台端个人中心）——业务静态页。
class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账号安全')),
      body: const AccountSecurityBody(),
    );
  }
}

/// 账号安全正文（供个人中心对话框内容区内嵌展示）。
class AccountSecurityBody extends StatelessWidget {
  const AccountSecurityBody({super.key, this.onOpenPage});

  /// 打开个人中心下的其它页面（如「多因素认证」），由个人中心外壳注入；
  /// 为空时（整页路由 / 单页预览）退化为 push 对应整页。
  final ValueChanged<String>? onOpenPage;

  void _openMfa(BuildContext context) {
    final onOpenPage = this.onOpenPage;
    if (onOpenPage != null) {
      onOpenPage('多因素认证');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MfaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _item(
          context,
          Icons.lock_outline,
          '登录密码',
          '已设置',
          '修改密码',
          onAction: () {},
          extraAction: '设置密码',
          onExtraAction: () {},
        ),
        _item(
          context,
          Icons.smartphone,
          '手机号',
          '138****1234',
          '更换',
          onAction: () {},
        ),
        _item(
          context,
          Icons.mail_outline,
          '邮箱',
          'nick@example.com',
          '更换',
          onAction: () {},
        ),
        _item(
          context,
          Icons.verified_user_outlined,
          '多因素认证',
          '未开启',
          '开启',
          onAction: () => _openMfa(context),
        ),
        _item(
          context,
          Icons.receipt_long_outlined,
          '账号日志',
          '最近登录：2024-08-18 10:12',
          '查看',
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String action, {
    VoidCallback? onAction,
    String? extraAction,
    VoidCallback? onExtraAction,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (extraAction != null)
              TextButton(
                onPressed: onExtraAction ?? () {},
                child: Text(extraAction),
              ),
            TextButton(onPressed: onAction ?? () {}, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
