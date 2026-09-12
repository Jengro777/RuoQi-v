// 运营后台入口弹窗（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 交互方式与 管理后台（系统管理）一致：点击左侧菜单项后，
// 在弹窗右侧内容区直接打开对应的真实业务页，不再 push 完整页面路由。
// 弹窗顶部为按规范 §6.7 实现的控制台导航栏（品牌 + 退出）；
// 菜单导航全部在左侧树形菜单中（板块 → 页面），来源为真实业务页。
import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'operations_nav.dart';
import 'operations_sidebar.dart';

/// 运营后台（一账通运营端 SSO）入口弹窗。
class OperationsConsoleDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => const _OperationsConsoleDialog(),
    );
  }
}

class _OperationsConsoleDialog extends StatefulWidget {
  const _OperationsConsoleDialog();

  @override
  State<_OperationsConsoleDialog> createState() =>
      _OperationsConsoleDialogState();
}

class _OperationsConsoleDialogState extends State<_OperationsConsoleDialog> {
  OperationsNavItem? _selected;

  @override
  void initState() {
    super.initState();
    // 默认打开第一个板块的第一个菜单项，与 管理后台 一致。
    final first = operationsNavSections.first;
    _selected = first.items.isEmpty ? null : first.items.first;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 顶部导航栏：品牌 + 退出
          ConsoleTopBar(
            title: 'XX运营后台',
            onExit: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左侧菜单
                OperationsSidebar(
                  selectedId: selected?.label,
                  onSelected: (item) => setState(() => _selected = item),
                ),
                // 右侧内容区：展示选中菜单项对应的真实业务页
                Expanded(
                  child: selected == null
                      ? ColoredBox(color: Theme.of(context).colorScheme.surface)
                      : ColoredBox(
                          key: ValueKey(selected.label),
                          color: Theme.of(context).colorScheme.surface,
                          child: selected.builder(context),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
