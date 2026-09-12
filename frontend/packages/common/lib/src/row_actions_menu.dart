import 'package:flutter/material.dart';

/// 行内动作项：菜单文案 + 回调。
class RuQiRowAction {
  const RuQiRowAction(this.label, this.onSelected);

  final String label;
  final VoidCallback onSelected;
}

/// 表格「操作」列的行内动作菜单：一个 `···` 按钮 + 下拉菜单。
///
/// 与「用户」页的操作列一致：动作在三个及以上时统一收进菜单，
/// 避免操作列堆一排按钮。菜单项默认中性文本，hover 由主题中性高亮承担。
class RuQiRowActionsMenu extends StatefulWidget {
  const RuQiRowActionsMenu({
    super.key,
    required this.actions,
    this.tooltip = '操作',
  });

  final List<RuQiRowAction> actions;
  final String tooltip;

  @override
  State<RuQiRowActionsMenu> createState() => _RuQiRowActionsMenuState();
}

class _RuQiRowActionsMenuState extends State<RuQiRowActionsMenu> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      // 命中区固定 36×36：避免被表格单元格的紧约束拉成整格宽，
      // hover 时只有图标高亮，不会出现一整片灰色。
      child: PopupMenuButton<String>(
        tooltip: widget.tooltip,
        onSelected: (label) {
          for (final action in widget.actions) {
            if (action.label == label) {
              action.onSelected();
              return;
            }
          }
        },
        itemBuilder: (context) => [
          for (final action in widget.actions)
            PopupMenuItem<String>(
              value: action.label,
              height: 36,
              child: Text(
                action.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
        ],
        // 悬停只把 `···` 图标转主色，不加灰色圆底（与行内文字动作一致）。
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.more_horiz,
              size: 20,
              color: _hovered
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
