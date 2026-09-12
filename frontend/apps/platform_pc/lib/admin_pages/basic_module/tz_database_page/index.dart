import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'tz_database_models.dart';
import 'tz_database_toast.dart';
import 'tz_sync_confirm_dialog.dart';

/// 基础-时区数据库 业务正文（对应 时区数据库 原型）。
class TzDatabaseBody extends StatelessWidget {
  const TzDatabaseBody({super.key});

  Future<void> _sync(BuildContext context) async {
    final confirmed = await showTzDatabaseSyncConfirm(context);
    if (confirmed == true && context.mounted) {
      showTzDatabaseToast(context, '时区数据库已同步（演示）');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '时区数据库',
          description: '基于 IANA 时区数据库维护各时区偏移与夏令时规则。',
          actionLabel: '同步',
          onAction: () => _sync(context),
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
                  '时区数据库（通常称为 tz 或 zoneinfo）包含代表全球许多代表性'
                  '地点的本地时间历史的代码和数据。它会定期更新以反映政治机构对'
                  '时区边界、UTC 偏移量和夏令时规则所做的更改。'
                  '数据来源：https://www.iana.org/time-zones',
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
            (label: '时区ID', flex: 16),
            (label: 'UTC 偏移量', flex: 10),
            (label: '夏令时', flex: 24),
            (label: '示例城市', flex: 12),
          ],
          rowCount: tzDatabaseEntries.length,
          rowBuilder: (context, index) {
            final entry = tzDatabaseEntries[index];
            return [
              CellText(entry.id, strong: true),
              CellText(entry.zoneId),
              CellText(entry.offset, muted: true),
              CellText(entry.dst, muted: true),
              CellText(entry.city, muted: true),
            ];
          },
        ),
      ],
    );
  }
}
