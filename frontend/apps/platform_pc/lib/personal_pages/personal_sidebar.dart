import 'package:flutter/material.dart';

import 'personal_nav.dart';

/// 个人中心左侧菜单：宽 300、右侧 1px 描边、选中项 `primaryContainer`。
///
/// 只有四个固定页面，因此不做搜索框与树形展开，与 管理后台 / 运营后台
/// 的选中态样式保持一致。
class PersonalSidebar extends StatelessWidget {
  const PersonalSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// 与 管理后台 / 运营后台 左侧菜单同宽。
  static const double width = 300;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: personalNavItems.length,
        itemBuilder: (context, index) {
          final item = personalNavItems[index];
          final selected = index == selectedIndex;
          return InkWell(
            onTap: () => onSelected(index),
            child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 40),
              color: selected
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
