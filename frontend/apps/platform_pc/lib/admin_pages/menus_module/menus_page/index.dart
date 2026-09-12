import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'menu_delete_confirm_dialog.dart';
import 'menu_edit_modal.dart';
import 'menu_models.dart';
import 'menu_toast.dart';

/// 菜单板块业务正文（对应 菜单 原型）。
class MenusBody extends StatelessWidget {
  const MenusBody({super.key});

  Future<void> _handleAction(
    BuildContext context,
    MenuItem item,
    String action,
  ) async {
    switch (action) {
      case '新增下级':
        await showMenuEditPanel(context, parent: item.name);
      case '编辑':
        await showMenuEditPanel(context, item: item);
      case '删除':
        final confirmed = await showMenuDeleteConfirm(context, item);
        if (confirmed == true && context.mounted) {
          showMenuToast(context, '已删除菜单 ${item.name}');
        }
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
          title: '菜单',
          description: '通过菜单控制管理后台左侧导航的展示位置与权限。',
          actionLabel: '添加',
          onAction: () => showMenuEditPanel(context),
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
                  '你可以使用菜单来自由控制其展示的位置。一般这个由专业人员设置，'
                  '不建议将此权限开放给普通人员。',
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
            (label: '名称', flex: 12),
            (label: '类型', flex: 8),
            (label: '图标', flex: 8),
            (label: '组件路径', flex: 18),
            (label: '权限标识', flex: 16),
            (label: '网页URL', flex: 14),
            (label: '排序', flex: 6),
            (label: '操作', flex: 18),
          ],
          rowCount: menuItems.length,
          rowBuilder: (context, index) {
            final item = menuItems[index];
            return [
              CellText(item.name, strong: true),
              CellText(item.type, muted: item.parent != '根目录'),
              CellText(item.icon.isEmpty ? '--' : item.icon, muted: true),
              CellText(
                item.componentPath.isEmpty ? '--' : item.componentPath,
                muted: true,
              ),
              CellText(
                item.permissionKey.isEmpty ? '--' : item.permissionKey,
                muted: true,
              ),
              CellText(item.url.isEmpty ? '--' : item.url, muted: true),
              CellText('${item.sort}', muted: true),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, item, '新增下级'),
                    child: const Text('新增下级'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, item, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, item, '删除'),
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
