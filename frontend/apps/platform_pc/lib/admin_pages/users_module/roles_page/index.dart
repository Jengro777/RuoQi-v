import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'create_role_modal.dart';
import 'delete_role_confirm_dialog.dart';
import 'edit_role_modal.dart';
import 'role_permissions_modal.dart';
import 'role_toast.dart';

/// 管理后台-角色 业务正文（对应 角色 原型）。
///
/// 角色组表格 + 创建 / 编辑 / 设置权限 / 删除操作；
/// 管理员与所有用户为特殊默认组，不可删除。
class RolesBody extends StatelessWidget {
  const RolesBody({super.key, this.onOpenPermissions});

  /// 点击「设置权限」时跳转到权限板块；为空时回退到站内权限面板。
  final VoidCallback? onOpenPermissions;

  Future<void> _handleAction(
    BuildContext context,
    RoleGroup role,
    String action,
  ) async {
    switch (action) {
      case '编辑名称':
        await showEditRolePanel(context, role);
      case '设置权限':
        if (onOpenPermissions != null) {
          onOpenPermissions!();
        } else {
          await showRolePermissionsPanel(context, role);
        }
      case '删除角色组':
        if (role.isDefault) {
          showRoleToast(context, '${role.name} 是特殊默认组，不能被删除');
          return;
        }
        final confirmed = await showDeleteRoleConfirmDialog(context, role);
        if (confirmed && context.mounted) {
          showRoleToast(context, '已删除角色组 ${role.name}');
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
          title: '角色',
          description: '通过角色组控制用户对数据的访问。',
          actionLabel: '创建角色组',
          onAction: () => showCreateRolePanel(context),
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
                  '你可以使用组来控制你的用户对你的数据的访问。把用户放在组里，'
                  '然后到权限部分去控制每个组的访问。管理员和所有用户组是特殊的'
                  '默认组，不能被删除。',
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
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: theme.colorScheme.surfaceContainerHigh,
                padding: const EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.lg,
                  vertical: RuQiSpacing.sm,
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 20, child: UserColumnHeader('角色名称')),
                    Expanded(flex: 10, child: UserColumnHeader('名称')),
                    Expanded(flex: 10, child: UserColumnHeader('成员')),
                    Expanded(flex: 24, child: UserColumnHeader('备注')),
                    Expanded(flex: 12, child: UserColumnHeader('操作')),
                  ],
                ),
              ),
              const Divider(height: 1),
              for (final (index, role) in roleGroups.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.lg,
                    vertical: RuQiSpacing.sm,
                  ),
                  decoration: index == roleGroups.length - 1
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
                    children: [
                      Expanded(
                        flex: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Row(
                            children: [
                              UserAvatar(label: role.initial, size: 32),
                              const SizedBox(width: RuQiSpacing.sm),
                              Expanded(
                                child: Text(
                                  role.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            role.initial,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            '${role.memberCount}',
                            style: RuQiTextStyles.tabular.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 24,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            role.note,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 12,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: PopupMenuButton<String>(
                            tooltip: '操作',
                            icon: Icon(
                              Icons.more_horiz,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onSelected: (action) =>
                                _handleAction(context, role, action),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: '编辑名称',
                                child: Text('编辑名称'),
                              ),
                              const PopupMenuItem(
                                value: '设置权限',
                                child: Text('设置权限'),
                              ),
                              const PopupMenuItem(
                                value: '删除角色组',
                                child: Text('删除角色组'),
                              ),
                            ],
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
        UserPagination(total: roleGroups.length, pageSize: 10),
      ],
    );
  }
}
