import 'package:flutter/material.dart';

import 'sms_login_page.dart';

/// APP 登录方式选择（终端用户）——业务静态页。
class LoginMethodsPage extends StatelessWidget {
  const LoginMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.verified_user_outlined, size: 64, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                '欢迎使用一账通',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              _method(
                context,
                icon: Icons.password,
                title: '密码登录',
                subtitle: '使用手机号 / 邮箱 / 用户名',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _method(
                context,
                icon: Icons.sms_outlined,
                title: '手机验证码登录',
                subtitle: '使用手机号接收验证码',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SmsLoginPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _method(
                context,
                icon: Icons.mail_outline,
                title: '邮箱验证码登录',
                subtitle: '使用邮箱接收验证码',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _method(
                context,
                icon: Icons.phone_iphone,
                title: '本机号码一键验证',
                subtitle: '运营商快速验证当前号码',
                onTap: () {},
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('第三方登录', style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _social(context, Icons.wechat, '微信'),
                  const SizedBox(width: 28),
                  _social(context, Icons.g_mobiledata, 'Google'),
                  const SizedBox(width: 28),
                  _social(context, Icons.apple, 'Apple'),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('还没有账户？立即注册'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _method(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _social(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 24, child: Icon(icon, size: 26)),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
