import 'package:flutter/material.dart';

/// 协议勾选弹窗（APP 终端用户）——业务静态弹窗。
class AgreementDialog extends StatelessWidget {
  const AgreementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AgreementDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.description_outlined, size: 48, color: colorScheme.primary),
      title: const Text('服务协议与隐私政策'),
      content: const Text(
        '请阅读并同意《隐私政策》《用户服务协议》',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('我再想想'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('同意'),
        ),
      ],
    );
  }
}
