import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'currency_edit_modal.dart';
import 'currency_models.dart';
import 'currency_toast.dart';
import 'delete_confirm_dialog.dart';

/// 基础-货币 业务正文（对应 货币 原型）。
class CurrencyBody extends StatelessWidget {
  const CurrencyBody({super.key});

  Future<void> _handleAction(
    BuildContext context,
    Currency currency,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showCurrencyEditPanel(context, currency: currency);
      case '启用':
        showCurrencyToast(context, '已启用 ${currency.zhName}');
      case '停用':
        showCurrencyToast(context, '已停用 ${currency.zhName}');
      case '删除':
        final confirmed = await showCurrencyDeleteConfirm(context, currency);
        if (confirmed == true && context.mounted) {
          showCurrencyToast(context, '已删除 ${currency.zhName}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '货币',
          description: '维护平台计价货币与汇率浮动配置。',
          actionLabel: '添加',
          onAction: () => showCurrencyEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '货币代码', flex: 8),
            (label: '符号', flex: 6),
            (label: '货币名称', flex: 10),
            (label: '小数位', flex: 6),
            (label: '汇率浮动', flex: 8),
            (label: '网站汇率', flex: 8),
            (label: '实时汇率', flex: 10),
            (label: '基础货币', flex: 8),
            (label: '状态', flex: 7),
            (label: '操作', flex: 18),
          ],
          rowCount: currencies.length,
          rowBuilder: (context, index) {
            final currency = currencies[index];
            return [
              CellText(currency.code, strong: true),
              CellText(currency.symbol, muted: true),
              CellText('${currency.zhName} / ${currency.enName}'),
              CellText('${currency.decimals}', muted: true),
              CellText(currency.rateFloat, muted: true),
              CellText(currency.siteRate, muted: true),
              CellText(currency.liveRate, muted: true),
              Text(
                currency.isBase ? '是' : '无',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: currency.isBase
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: currency.isBase ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              StatusBadge(
                label: currency.enabled ? '启用中' : '已停用',
                tone: currency.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, currency, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      currency,
                      currency.enabled ? '停用' : '启用',
                    ),
                    child: Text(currency.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, currency, '删除'),
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
      ],
    );
  }
}
