import 'package:flutter/material.dart';

/// 手机号未注册提示弹窗（APP 终端用户）——业务静态弹窗。
class PhoneNotRegisteredDialog extends StatelessWidget {
  const PhoneNotRegisteredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const PhoneNotRegisteredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('手机号未注册'),
      content: const Text(
        '手机号 +86 15020579521 未注册。\n点击「继续注册」将跳转到手机号注册流程。',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('继续注册'),
        ),
      ],
    );
  }
}
