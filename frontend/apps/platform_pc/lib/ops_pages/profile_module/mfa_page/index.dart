import 'package:flutter/material.dart';

/// 多因素认证（运营后台·个人中心）——业务静态页。
class MfaPage extends StatelessWidget {
  const MfaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多因素认证')),
      body: const MfaBody(),
    );
  }
}

/// 多因素认证正文（供运营后台对话框右侧内容区内嵌展示）。
class MfaBody extends StatelessWidget {
  const MfaBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _method(context, Icons.sms_outlined, '短信验证码', '已开启', true),
        _method(context, Icons.mail_outline, '邮箱验证码', '未开启', false),
        _method(context, Icons.apps, '认证器 App（TOTP）', '未开启', false),
        _method(context, Icons.grid_on, '备用验证码', '未开启', false),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '开启多因素认证后，登录时需要额外的验证步骤，以提升账号安全性。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _method(
    BuildContext context,
    IconData icon,
    String title,
    String status,
    bool enabled,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(status),
        trailing: Switch(
          value: enabled,
          onChanged: (_) {},
        ),
      ),
    );
  }
}
