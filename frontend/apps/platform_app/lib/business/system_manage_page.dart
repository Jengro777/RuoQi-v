import 'package:flutter/material.dart';

import '../prototype_registry.dart';
import '../prototype_viewer.dart';

/// 系统管理（运营端 App）——独立入口页面。
///
/// 对应 IDM 原型包 (1) 运营端下的 App 端页面（个人中心、账号安全等），
/// 按模块分组展示全部原型页面，点击进入查看。
class SystemManagePage extends StatelessWidget {
  const SystemManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PrototypeEntry>>{};
    for (final e in prototypePages) {
      grouped.putIfAbsent(e.path.split('/').first, () => []).add(e);
    }
    final keys = grouped.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('系统管理')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            '共 ${prototypePages.length} 个运营端 App 页面',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          for (final key in keys) ...[
            ExpansionTile(
              title: Text(key),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final e in grouped[key]!)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.description_outlined, size: 18),
                    title: Text(e.title),
                    subtitle: Text(e.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrototypeViewer(entry: e),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
