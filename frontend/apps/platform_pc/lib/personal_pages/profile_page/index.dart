import 'package:flutter/material.dart';

import '../account_security_page/index.dart';
import '../localization_page/index.dart';
import '../mfa_page/index.dart';

/// 个人资料（平台端个人中心）——业务静态页。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: const ProfileBody(),
    );
  }
}

/// 个人资料正文（供个人中心对话框内容区内嵌展示）。
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key, this.onOpenPage});

  /// 打开个人中心下的其它页面（如「账号安全」），由个人中心外壳注入；
  /// 为空时（整页路由 / 单页预览）退化为 push 对应整页。
  final ValueChanged<String>? onOpenPage;

  /// 页面内跳转：外壳内切换菜单选中项，独立打开时 push 整页路由。
  void _openPage(BuildContext context, String label, Widget page) {
    final onOpenPage = this.onOpenPage;
    if (onOpenPage != null) {
      onOpenPage(label);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

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
        // 个人中心下的其它页面
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _navTile(
                context,
                icon: Icons.verified_user_outlined,
                title: '账号安全',
                onTap: () =>
                    _openPage(context, '账号安全', const AccountSecurityPage()),
              ),
              _navTile(
                context,
                icon: Icons.apps,
                title: '多因素认证',
                onTap: () =>
                    _openPage(context, '多因素认证', const MfaPage()),
              ),
              _navTile(
                context,
                icon: Icons.language,
                title: '本地化',
                onTap: () => _openPage(context, '本地化', const LocalizationPage()),
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
