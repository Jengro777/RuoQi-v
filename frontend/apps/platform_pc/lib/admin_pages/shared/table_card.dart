import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 表格列定义：标签 + 宽度权重。
typedef TableColumn = ({String label, int flex});

/// 表格单元格文本：主文本 / 弱化文本 / 强调文本。
class CellText extends StatelessWidget {
  const CellText(
    this.text, {
    super.key,
    this.muted = false,
    this.strong = false,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;
  final bool muted;
  final bool strong;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      overflow: overflow,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: muted
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurface,
        fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

/// 规范 §6.4 表格卡片：`surfaceContainerHigh` 表头 + `outlineVariant` 分隔行。
///
/// [rowBuilder] 返回与 [columns] 一一对应的单元格内容（无需自行包 `Expanded`），
/// 行内每格按列的 flex 自动撑开。
class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowBuilder,
    this.emptyText = '暂无数据',
  });

  final List<TableColumn> columns;
  final int rowCount;
  final List<Widget> Function(BuildContext context, int index) rowBuilder;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: theme.colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.symmetric(
              horizontal: RuQiSpacing.lg,
              vertical: RuQiSpacing.sm,
            ),
            child: Row(
              children: [
                for (final column in columns)
                  Expanded(
                    flex: column.flex,
                    child: Text(
                      column.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rowCount == 0)
            Padding(
              padding: const EdgeInsets.all(RuQiSpacing.lg),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var i = 0; i < rowCount; i++)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.lg,
                  vertical: RuQiSpacing.sm,
                ),
                decoration: i == rowCount - 1
                    ? null
                    : BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                      ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var c = 0; c < columns.length; c++)
                      Expanded(
                        flex: columns[c].flex,
                        child: rowBuilder(context, i)[c],
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
