import 'package:flutter/material.dart';

/// 设备管理（APP 终端用户）——业务静态页。
class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('设备管理')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _device(
            context,
            Icons.phone_iphone,
            'iPhone 15',
            '当前设备 · 北京',
            '2024-08-12 10:04',
            true,
            colorScheme,
          ),
          _device(
            context,
            Icons.laptop_mac,
            'MacBook Pro',
            '北京',
            '2024-08-10 09:30',
            false,
            colorScheme,
          ),
          _device(
            context,
            Icons.desktop_windows,
            'Windows PC',
            '上海',
            '2024-07-28 18:22',
            false,
            colorScheme,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '移除设备后，该设备将需要重新登录。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _device(
    BuildContext context,
    IconData icon,
    String name,
    String location,
    String time,
    bool current,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(name),
        subtitle: Text('$location · $time'),
        trailing: current
            ? Chip(
                label: const Text('当前设备'),
                backgroundColor: colorScheme.primaryContainer,
              )
            : TextButton(onPressed: () {}, child: const Text('移除')),
      ),
    );
  }
}
