import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'rate_history_edit_modal.dart';
import 'rate_history_models.dart';
import 'rate_history_toast.dart';

/// 基础-历史汇率 业务正文（对应 历史汇率 原型）。
class RateHistoryBody extends StatelessWidget {
  const RateHistoryBody({super.key});

  Future<void> _handleAction(
    BuildContext context,
    RateHistory rate,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showRateHistoryEditPanel(context, rate: rate);
      case '启用':
        showRateHistoryToast(context, '已启用该汇率记录');
      case '停用':
        showRateHistoryToast(context, '已停用该汇率记录');
      case '删除':
        showRateHistoryToast(context, '已删除该汇率记录');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '历史汇率',
          description: '查看与维护各货币对的历史汇率记录。',
          actionLabel: '添加',
          onAction: () => showRateHistoryEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '汇率类型', flex: 10),
            (label: '原货币', flex: 7),
            (label: '目标货币', flex: 7),
            (label: '原汇率', flex: 8),
            (label: '汇率浮动', flex: 8),
            (label: '网站汇率', flex: 8),
            (label: '生效时间', flex: 13),
            (label: '结束时间', flex: 13),
            (label: '操作账号', flex: 9),
            (label: '状态', flex: 7),
            (label: '操作', flex: 16),
          ],
          rowCount: rateHistories.length,
          rowBuilder: (context, index) {
            final rate = rateHistories[index];
            return [
              CellText(rate.type, strong: true),
              CellText(rate.from, muted: true),
              CellText(rate.to, muted: true),
              CellText(rate.originalRate, muted: true),
              CellText(rate.rateFloat, muted: true),
              CellText(rate.siteRate, muted: true),
              CellText(rate.effectiveAt, muted: true),
              CellText(rate.expireAt, muted: true),
              CellText(rate.account, muted: true),
              StatusBadge(
                label: rate.enabled ? '启用中' : '已停用',
                tone: rate.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, rate, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      rate,
                      rate.enabled ? '停用' : '启用',
                    ),
                    child: Text(rate.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, rate, '删除'),
                    child: Text(
                      '删除',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
        const SizedBox(height: RuQiSpacing.md),
        UserPagination(total: 125),
      ],
    );
  }
}
