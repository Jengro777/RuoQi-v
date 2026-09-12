import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 伙伴端（PC）原型首页：合作伙伴中心。
class PartnerHomePage extends StatelessWidget {
  const PartnerHomePage({super.key, this.embedded = false});

  /// 嵌入业务工作台弹窗时去掉自带 AppBar（弹窗顶部已有控制台导航栏）。
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '合作伙伴中心',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const AppBadge(appName: 'partner_pc', version: '1.0.0'),
        ],
      ),
    );

    if (embedded) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: body,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('RuoQi 伙伴')),
      body: body,
    );
  }
}
