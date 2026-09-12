import 'package:flutter/material.dart';

import '../../operations_action_dialog.dart';
import '../account_security_page/index.dart';
import '../localization_page/index.dart';
import '../mfa_page/index.dart';

/// PC 个人中心（基本信息）（运营后台）——业务静态页。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: const ProfileBody(),
    );
  }
}

/// 个人中心正文（供运营后台对话框右侧内容区内嵌展示）。
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nick',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'nick@example.com',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton(onPressed: () {}, child: const Text('更换头像')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '基本信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '姓名',
                  child: const TextField(
                    decoration: InputDecoration(hintText: 'Nick'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '邮箱',
                  child: const TextField(
                    decoration: InputDecoration(hintText: 'nick@example.com'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '手机号',
                  child: const TextField(
                    decoration: InputDecoration(hintText: '138****1234'),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 个人中心子功能：以弹窗方式打开
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _navTile(
                context,
                icon: Icons.verified_user_outlined,
                title: '账号安全',
                onTap: () => showOperationsActionDialog(
                  context,
                  title: '账号安全',
                  child: const AccountSecurityBody(),
                ),
              ),
              _navTile(
                context,
                icon: Icons.apps,
                title: '多因素认证',
                onTap: () => showOperationsActionDialog(
                  context,
                  title: '多因素认证',
                  child: const MfaBody(),
                ),
              ),
              _navTile(
                context,
                icon: Icons.language,
                title: '本地化',
                onTap: () => showOperationsActionDialog(
                  context,
                  title: '本地化',
                  child: const LocalizationBody(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(label),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
