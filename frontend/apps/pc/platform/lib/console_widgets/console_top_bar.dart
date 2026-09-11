import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 控制台顶部导航条（规范 §6.7）。
///
/// `surface` 背景 + `onSurface` 文本、高 56、无阴影；
/// 左侧 Logo + 标题，中间板块 Tab（选中项主色 + 下划线指示条），
/// 右侧退出按钮（`button-secondary` 样式）。
class ConsoleTopBar extends StatelessWidget {
  const ConsoleTopBar({
    super.key,
    required this.title,
    required this.onExit,
    this.tabs = const [],
    this.sectionIndex = -1,
    this.onSectionSelected,
  });

  /// 控制台名称，如「XX管理后台」。
  final String title;

  final VoidCallback onExit;

  /// 板块 Tab 标签。
  final List<String> tabs;

  /// 当前选中 Tab 索引。
  final int sectionIndex;

  final ValueChanged<int>? onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: RuQiSpacing.md),
          Icon(Icons.bolt_rounded, size: 26, color: theme.colorScheme.primary),
          const SizedBox(width: RuQiSpacing.xs),
          Text(
            'RuoQi',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: RuQiSpacing.sm),
          Container(
            width: 1,
            height: 20,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(width: RuQiSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: RuQiSpacing.lg),
          for (var i = 0; i < tabs.length; i++)
            _ConsoleTab(
              label: tabs[i],
              selected: i == sectionIndex,
              onTap: () => onSectionSelected?.call(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: RuQiSpacing.md),
            child: OutlinedButton(
              onPressed: onExit,
              style: RuQiButtonStyles.secondary(context),
              child: const Text('退出'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleTab extends StatelessWidget {
  const _ConsoleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
