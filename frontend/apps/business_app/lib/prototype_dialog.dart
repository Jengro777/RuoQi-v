import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// 业务原型的统一弹窗壳：控制台顶栏（品牌 + 退出）+ 原型内容。
///
/// 与 PC 端 `business_pc` 完全一致：铺满窗口、`surface` 背景、
/// 顶栏提供标题与退出；原型自带的 AppBar 由 `embedded: true` 隐藏。
class PrototypeDialog {
  const PrototypeDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        child: Column(
          children: [
            ConsoleTopBar(
              title: title,
              onExit: () => Navigator.of(dialogContext).pop(),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
