import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 业务原型的统一弹窗壳：控制台顶栏（品牌 + 退出）+ 原型内容。
///
/// 与平台端「系统管理 / 运营后台」弹窗保持一致：铺满窗口、`surface` 背景、
/// 顶栏提供标题与退出；正文区承载原型页面，原型自带的 AppBar 由
/// `embedded: true` 隐藏，避免出现两条顶栏。
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
