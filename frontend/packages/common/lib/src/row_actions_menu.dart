import 'package:flutter/material.dart';

import 'theme/tokens.dart';

/// 行内动作项：菜单文案 + 回调。
class RuQiRowAction {
  const RuQiRowAction(this.label, this.onSelected);

  final String label;
  final VoidCallback onSelected;
}

/// 表格「操作」列的行内动作菜单：一个 `···` 按钮 + 下拉菜单。
///
/// 与「用户」页的操作列一致：动作在三个及以上时统一收进菜单。交互上
/// 一律「默认中性、hover 亮色」——`···` 与菜单项都只在悬停时把文字转
/// `primary`，不铺灰底、不留灰色圆底。
class RuQiRowActionsMenu extends StatefulWidget {
  const RuQiRowActionsMenu({
    super.key,
    required this.actions,
    this.semanticsLabel = '操作',
  });

  final List<RuQiRowAction> actions;

  /// 无障碍标签（不渲染为 tooltip，避免 hover 时弹出灰色浮层）。
  final String semanticsLabel;

  @override
  State<RuQiRowActionsMenu> createState() => _RuQiRowActionsMenuState();
}

class _RuQiRowActionsMenuState extends State<RuQiRowActionsMenu> {
  final MenuController _menuController = MenuController();
  bool _hovered = false;

  void _toggleMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 命中区固定 36×36：避免被表格单元格的紧约束拉成整格宽。
    return Align(
      alignment: Alignment.centerLeft,
      child: MenuAnchor(
        controller: _menuController,
        // 菜单面板沿用卡片口径：白底 + 1px 描边 + 圆角。
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(4),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: RuQiSpacing.xxs),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RuQiSpacing.xs),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
        ),
        menuChildren: [
          for (final action in widget.actions)
            MenuItemButton(
              onPressed: action.onSelected,
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(180, 36)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: RuQiSpacing.md),
                ),
                // 不要灰底 / 水波纹，反馈只落在文字颜色上。
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.focused) ||
                          states.contains(WidgetState.pressed)
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                textStyle: WidgetStatePropertyAll(theme.textTheme.bodyMedium),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(action.label),
              ),
            ),
        ],
        builder: (context, controller, child) => Semantics(
          button: true,
          label: widget.semanticsLabel,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleMenu,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: _hovered
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
