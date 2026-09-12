import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'utc_zone_edit_modal.dart';
import 'utc_zone_models.dart';

/// 基础-UTC 业务正文（对应 时区 原型）。
class UtcBody extends StatelessWidget {
  const UtcBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '协调世界时',
          description: 'UTC 时区划分与中央经线对照。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Container(
          padding: const EdgeInsets.all(RuQiSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: ext?.info ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: RuQiSpacing.sm),
              Expanded(
                child: Text(
                  '1. 协调世界时（UTC：Coordinated Universal Time），又称世界统一时间、'
                  '世界标准时间；\n2. 计算的区时 = 已知区时 -（已知区时的时区 - 要计算'
                  '区时的时区）（东时区为正，西时区为负）；\n3. 区时定义：本时区的中央'
                  '经线的地方时（区时是整数的）。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'ID', flex: 6),
            (label: '时区', flex: 10),
            (label: '时区中心线', flex: 12),
            (label: '经度范围', flex: 16),
            (label: '操作', flex: 8),
          ],
          rowCount: utcZoneRows.length,
          rowBuilder: (context, index) {
            final row = utcZoneRows[index];
            return [
              CellText(row.id, strong: true),
              CellText(row.label),
              CellText(row.center, muted: true),
              CellText(row.range, muted: true),
              TextButton(
                style: RuQiButtonStyles.tertiary(context),
                onPressed: () => showUtcZoneEditPanel(context, row),
                child: const Text('编辑'),
              ),
            ];
          },
        ),
      ],
    );
  }
}
