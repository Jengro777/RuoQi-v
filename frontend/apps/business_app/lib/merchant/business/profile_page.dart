import 'package:flutter/material.dart';

import 'account_security_page.dart';

/// 用户个人中心（APP 终端用户）——业务静态页。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          // 用户信息头部
          Container(
            padding: const EdgeInsets.all(20),
            color: colorScheme.primaryContainer,
            child: Row(
              children: [
                const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('点击登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        '登录后同步账号与设备数据',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  tooltip: '我的二维码',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          _section(context, '常用功能', [
            _tile(context, '家庭房间管理', Icons.home_outlined),
            _tile(context, '消息中心', Icons.notifications_none),
            _tile(context, '我的二维码', Icons.qr_code),
            _tile(context, '更多', Icons.more_horiz),
          ]),
          _section(context, '账号与安全', [
            _tile(context, '账号安全', Icons.security_outlined, onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountSecurityPage()),
              );
            }),
            _tile(context, '设置', Icons.settings_outlined),
            _tile(context, '用户协议和隐私政策', Icons.description_outlined),
            _tile(context, '帮助与反馈', Icons.help_outline),
          ]),
          _section(context, '第三方服务', [
            _tile(context, 'Alexa', Icons.camera_outdoor_outlined),
            _tile(context, 'Google Assistant', Icons.g_mobiledata),
            _tile(context, 'TmallGenie', Icons.speaker_outlined),
          ]),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 24),
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

  Widget _tile(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
