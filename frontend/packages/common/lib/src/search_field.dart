import 'package:flutter/material.dart';

import 'theme/tokens.dart';

/// 统一搜索输入框：全站同高（36）、同内边距、同前缀图标。
///
/// 侧栏菜单搜索、表格上方筛选搜索、下拉菜单内搜索都走这一个组件，
/// 避免各处 `isDense` / `contentPadding` 不同导致高度参差。
class RuQiSearchField extends StatelessWidget {
  const RuQiSearchField({
    super.key,
    required this.hintText,
    this.onChanged,
    this.controller,
    this.autofocus = false,
  });

  /// 搜索框高度（含 1px 描边）：全站统一。
  static const double height = 36;

  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 18),
          isDense: true,
          // 高度由外层 SizedBox 决定，内容垂直居中。
          contentPadding: const EdgeInsets.symmetric(
            horizontal: RuQiSpacing.xs,
            vertical: 0,
          ),
        ),
      ),
    );
  }
}
