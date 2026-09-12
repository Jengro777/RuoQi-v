import 'package:flutter/material.dart';

import 'theme/tokens.dart';
import 'search_field.dart';

/// 筛选下拉：与 [RuQiSearchField] 严格等高（36），描边 / 圆角与搜索框一致。
///
/// 不用 `DropdownButtonFormField`：它的 `InputDecorator` 按内容撑高，
/// 边框会画出参差的高度；这里用「固定高度 + 自带描边的容器 + 无下划线的
/// `DropdownButton`」，几何完全可控。
class RuQiFilterDropdown<T> extends StatelessWidget {
  const RuQiFilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  /// 描边圆角，与 `InputDecorationTheme` 的输入框一致。
  static const double _radius = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: RuQiSearchField.height,
      child: DecoratedBox(
        // 容器高度即描边高度：与搜索框逐像素一致。
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.sm),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              borderRadius: BorderRadius.circular(_radius),
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
