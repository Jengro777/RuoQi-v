import 'package:flutter/material.dart';

import '../theme/extension.dart';
import '../theme/tokens.dart';

/// 对比表单元格值。
class ComparisonCell {
  const ComparisonCell.text(String this.text) : isCheck = false;

  const ComparisonCell.check() : text = null, isCheck = true;

  const ComparisonCell.missing() : text = null, isCheck = false;

  /// 文本值；`null` 表示空值（渲染为 `—`）。
  final String? text;

  /// 勾选标记。
  final bool isCheck;
}

/// 对比表的一行：特性名 + 各列单元格。
class ComparisonRow {
  const ComparisonRow({required this.feature, required this.cells});

  final String feature;

  /// 长度需等于 `columns.length - 1`（不含特性列）。
  final List<ComparisonCell> cells;
}

/// 规范 §6.2 `ComparisonTable`：功能对比表。
///
/// 桌面（≥768px）标准表格；移动端（<768px）堆叠卡片，
/// 每行一张卡片，其余单元格渲染为「列名 + 值」。
class ComparisonTable extends StatelessWidget {
  const ComparisonTable({
    super.key,
    required this.columns,
    required this.rows,
    this.featuredColumn,
    this.compact = false,
    this.recommendedLabel = '推荐',
  });

  /// 表头列名（含首列特性列）。
  final List<String> columns;

  final List<ComparisonRow> rows;

  /// 推荐列（索引从 0 起，0 为特性列）：`primaryContainer` 背景 + 徽章。
  final int? featuredColumn;

  /// 紧凑变体：单元格 12/16、行高 40。
  final bool compact;

  final String recommendedLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 768;
        return wide ? _desktop(context) : _mobile(context);
      },
    );
  }

  Widget _desktop(BuildContext context) {
    final theme = Theme.of(context);
    final cellPadding = EdgeInsets.symmetric(
      horizontal: compact ? RuQiSpacing.md : RuQiSpacing.lg,
      vertical: compact ? RuQiSpacing.sm : RuQiSpacing.md,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 表头
          Container(
            color: theme.colorScheme.surfaceContainer,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++)
                  Expanded(
                    child: Padding(
                      padding: cellPadding,
                      child: _headerCell(context, i),
                    ),
                  ),
              ],
            ),
          ),
          // 数据行
          for (final (r, row) in rows.indexed)
            Container(
              decoration: BoxDecoration(
                border: r == rows.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < columns.length; i++)
                    Expanded(
                      child: Padding(
                        padding: cellPadding,
                        child: i == 0
                            ? Text(
                                row.feature,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              )
                            : _valueCell(
                                context,
                                row.cells[i - 1],
                                featured: i == featuredColumn,
                              ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isFeatured = index == featuredColumn;
    final header = Text(
      columns[index],
      textAlign: index == 0 ? TextAlign.left : TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
    if (!isFeatured) return header;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RuQiSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            recommendedLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        header,
      ],
    );
  }

  Widget _valueCell(
    BuildContext context,
    ComparisonCell cell, {
    required bool featured,
  }) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final content = cell.isCheck
        ? Icon(Icons.check, size: 18, color: ext.success)
        : cell.text != null
        ? Text(
            cell.text!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        : Text(
            '—',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: ext.inkTertiary),
          );
    return Container(
      alignment: Alignment.center,
      decoration: featured
          ? BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      padding: featured
          ? const EdgeInsets.symmetric(vertical: 4, horizontal: 4)
          : null,
      child: content,
    );
  }

  Widget _mobile(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final row in rows)
          Card(
            margin: const EdgeInsets.only(bottom: RuQiSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(RuQiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.feature,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.sm),
                  for (var i = 0; i < row.cells.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: RuQiSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            columns[i + 1],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).extension<RuQiThemeExtension>()!.inkMuted,
                            ),
                          ),
                          _valueCell(
                            context,
                            row.cells[i],
                            featured: (i + 1) == featuredColumn,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
