import 'package:flutter/material.dart';

/// 账号冻结弹窗（APP 终端用户）——业务静态弹窗。
class AccountFrozenDialog extends StatelessWidget {
  const AccountFrozenDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AccountFrozenDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.block, size: 48, color: colorScheme.error),
      title: const Text('账号被冻结'),
      content: const Text(
        '您的账号被系统冻结，请尽快联系客服解除冻结状态。',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {},
          child: const Text('联系客服'),
        ),
      ],
    );
  }
}
