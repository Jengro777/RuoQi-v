import 'package:flutter/material.dart';

/// 全站文案可选中复制：`MaterialApp.builder` 用的包裹函数。
///
/// ```dart
/// MaterialApp(builder: ruoQiSelectionBuilder, ...)
/// ```
///
/// 放在 `builder` 里而不是各个页面里，一次性覆盖所有路由与弹窗：
/// 版本号、端口、ID、说明文案都能直接拖选 / 长按取词。
///
/// `SelectionArea` 只接管「拖拽选择」手势，点击（入口卡片、按钮）、
/// 滚动、输入框编辑都不受影响；测试见 `widget_test` 的入口卡片点击用例。
Widget ruoQiSelectionBuilder(BuildContext context, Widget? child) {
  if (child == null) {
    return const SizedBox.shrink();
  }
  // SelectableRegion 需要「祖先里有 Overlay」来承载选区手柄与工具条，
  // 而 MaterialApp.builder 位于 Navigator（自带 Overlay）之上、又被
  // LookupBoundary 包住，看不到 Navigator 的 Overlay，所以这里自带一层
  // 只放一个条目的 Overlay；整棵页面树都在同一条条目里，
  // 因此路由、弹窗、下拉等仍共用一个选区。
  return Overlay(
    initialEntries: [
      OverlayEntry(
        builder: (_) => Positioned.fill(child: SelectionArea(child: child)),
      ),
    ],
  );
}
