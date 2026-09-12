import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'encoding_rule_edit_modal.dart';
import 'encoding_rule_models.dart';

/// 设置-编码规则 业务正文（替换静态原型复刻页）。
class EncodingRulesBody extends StatelessWidget {
  const EncodingRulesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          '编码规则',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '系统所有单号生成规则，以及单号前缀。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 表头：占满内容区宽度
              Container(
                color: theme.colorScheme.surfaceContainerHigh,
                padding: const EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.lg,
                  vertical: RuQiSpacing.sm,
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 15, child: _ColumnHeader('名称')),
                    Expanded(flex: 9, child: _ColumnHeader('单号前缀')),
                    Expanded(flex: 30, child: _ColumnHeader('生成单号规则')),
                    Expanded(flex: 30, child: _ColumnHeader('说明')),
                    Expanded(flex: 13, child: _ColumnHeader('操作')),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              for (final (i, rule) in encodingRules.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.lg,
                    vertical: RuQiSpacing.md,
                  ),
                  decoration: i == encodingRules.length - 1
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.prefix,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.rule,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.note,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 13,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton(
                            onPressed: () =>
                                showEncodingRuleEditDialog(context, rule),
                            style: RuQiButtonStyles.secondary(context),
                            child: const Text('编辑'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: RuQiSpacing.sm),
        Text(
          '共 ${encodingRules.length} 条 · 10条/页',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
