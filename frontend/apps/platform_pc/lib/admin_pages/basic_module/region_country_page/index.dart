import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'region_country_edit_modal.dart';
import 'region_country_models.dart';
import 'region_country_toast.dart';
import 'region_delete_confirm_dialog.dart';

/// 基础-地区&国家 业务正文（对应 地区&国家 原型）。
class RegionCountryBody extends StatelessWidget {
  const RegionCountryBody({super.key});

  Future<void> _handleAction(
    BuildContext context,
    RegionCountry region,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showRegionCountryEditPanel(context, region: region);
      case '启用':
        showRegionCountryToast(context, '已启用 ${region.zhName}');
      case '停用':
        showRegionCountryToast(context, '已停用 ${region.zhName}');
      case '删除':
        final confirmed = await showRegionDeleteConfirm(context, region);
        if (confirmed == true && context.mounted) {
          showRegionCountryToast(context, '已删除 ${region.zhName}');
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
          title: '地区&国家',
          description: '维护国家与地区的基础资料，供账户、支付等模块引用。',
          actionLabel: '添加',
          onAction: () => showRegionCountryEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '地区', flex: 12),
            (label: '两字母代码', flex: 8),
            (label: '三字母代码', flex: 8),
            (label: '数字代码', flex: 8),
            (label: '国际冠码', flex: 8),
            (label: '大洲代码', flex: 8),
            (label: '状态', flex: 8),
            (label: '操作', flex: 20),
          ],
          rowCount: regionCountries.length,
          rowBuilder: (context, index) {
            final region = regionCountries[index];
            return [
              CellText(region.zhName, strong: true),
              CellText(region.code2, muted: true),
              CellText(region.code3, muted: true),
              CellText(region.codeNum, muted: true),
              CellText(region.dialCode, muted: true),
              CellText(region.continent, muted: true),
              StatusBadge(
                label: region.enabled ? '启用中' : '已停用',
                tone: region.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, region, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      region,
                      region.enabled ? '停用' : '启用',
                    ),
                    child: Text(region.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, region, '删除'),
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
