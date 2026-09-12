import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

/// 打开设置权限面板。
Future<void> showRolePermissionsPanel(BuildContext context, RoleGroup role) {
  return showSystemSettingsPanel(
    context,
    title: '${role.name} · 权限',
    child: RolePermissionsPanel(role: role),
  );
}

/// 设置权限面板：模块 + 查看 / 编辑 开关（对应 权限 原型的一二级菜单）。
class RolePermissionsPanel extends StatefulWidget {
  const RolePermissionsPanel({super.key, required this.role});

  final RoleGroup role;

  @override
  State<RolePermissionsPanel> createState() => _RolePermissionsPanelState();
}

class _RolePermissionsPanelState extends State<RolePermissionsPanel> {
  late final Map<String, bool> _view;
  late final Map<String, bool> _edit;

  @override
  void initState() {
    super.initState();
    _view = {for (final (name, _) in permissionModules) name: true};
    _edit = {
      for (final (name, _) in permissionModules) name: widget.role.isDefault,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '为「${widget.role.name}」配置菜单与功能权限，'
                  '该组用户登录后将看到对应菜单。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                          horizontal: RuQiSpacing.md,
                          vertical: RuQiSpacing.sm,
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: UserColumnHeader('一级菜单')),
                            Expanded(flex: 3, child: UserColumnHeader('二级菜单')),
                            SizedBox(width: 64, child: UserColumnHeader('查看')),
                            SizedBox(width: 64, child: UserColumnHeader('编辑')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      for (final (index, (name, subMenus)) in permissionModules.indexed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RuQiSpacing.md,
                            vertical: RuQiSpacing.sm,
                          ),
                          decoration: index == permissionModules.length - 1
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
                                flex: 2,
                                child: Text(
                                  name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  subMenus.join(' / '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Switch(
                                  value: _view[name] ?? false,
                                  onChanged: (value) =>
                                      setState(() => _view[name] = value),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Switch(
                                  value: _edit[name] ?? false,
                                  onChanged: (value) =>
                                      setState(() => _edit[name] = value),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '保存修改', onConfirm: () => Navigator.of(context).pop()),
      ],
    );
  }
}
