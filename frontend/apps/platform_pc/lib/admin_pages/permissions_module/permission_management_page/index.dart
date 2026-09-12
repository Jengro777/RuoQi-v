import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'permission_save_confirm_dialog.dart';
import 'permission_toast.dart';

/// 管理后台-权限 业务正文（对应 权限 原型）。
///
/// 角色权限矩阵：系统范围选项卡（运营 / 管理）、角色列表、模块筛选、
/// 一级菜单 / 二级菜单 / 页面名称 + 查看 / 编辑 勾选；
/// 修改后出现「权限被修改」提示与 保存修改 / 取消，保存前弹出确认弹窗。
class PermissionsBody extends StatelessWidget {
  const PermissionsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PermissionManagementBody();
  }
}

/// 权限页可选角色（对应原型左侧角色列表）。
const _permissionRoles = ['Administrators', 'All Users', '实施专员'];

/// 系统范围选项卡（对应原型 运营 / 管理）。
const _permissionScopes = ['运营', '管理'];

/// 各系统范围下的一级菜单。
const _modulesByScope = <String, List<String>>{
  '运营': ['订单', '商品', '财务', '运营'],
  '管理': ['用户管理', '系统管理', '系统日志', '系统监控'],
};

List<String> _submenusOf(String module) {
  for (final entry in permissionModules) {
    if (entry.$1 == module) return entry.$2;
  }
  return const [];
}

/// 单个「角色 + 系统范围」的权限勾选状态与基线（用于 修改 / 保存 / 取消）。
class _RolePermissionState {
  _RolePermissionState({required this.view, required this.edit})
    : baselineView = Set.of(view),
      baselineEdit = Set.of(edit);

  Set<String> view;
  Set<String> edit;
  final Set<String> baselineView;
  final Set<String> baselineEdit;

  bool get modified =>
      !setEquals(view, baselineView) || !setEquals(edit, baselineEdit);

  void apply() {
    baselineView
      ..clear()
      ..addAll(view);
    baselineEdit
      ..clear()
      ..addAll(edit);
  }

  void revert() {
    view
      ..clear()
      ..addAll(baselineView);
    edit
      ..clear()
      ..addAll(baselineEdit);
  }

  /// 相对基线的 新增 / 取消 权限数量（查看 / 编辑 分开统计）。
  (int, int) diff() {
    final addedView = view.difference(baselineView).length;
    final removedView = baselineView.difference(view).length;
    final addedEdit = edit.difference(baselineEdit).length;
    final removedEdit = baselineEdit.difference(edit).length;
    return (addedView + addedEdit, removedView + removedEdit);
  }
}

class _PermissionManagementBody extends StatefulWidget {
  const _PermissionManagementBody();

  @override
  State<_PermissionManagementBody> createState() =>
      _PermissionManagementBodyState();
}

class _PermissionManagementBodyState extends State<_PermissionManagementBody> {
  String _role = 'Administrators';
  String _scope = '运营';
  String _filter = '所有权限';
  final Map<String, _RolePermissionState> _states = {};

  List<String> get _scopeModules => _modulesByScope[_scope] ?? const [];

  _RolePermissionState _state() {
    return _states.putIfAbsent('$_role|$_scope', () {
      final keys = <String>{
        for (final module in _scopeModules)
          for (final submenu in _submenusOf(module)) '$module/$submenu',
      };
      return _RolePermissionState(
        view: {...keys},
        edit: _role == 'Administrators' ? {...keys} : <String>{},
      );
    });
  }

  Future<void> _save() async {
    final state = _state();
    final (added, removed) = state.diff();
    final confirmed = await showPermissionSaveConfirm(
      context,
      role: _role,
      added: added,
      removed: removed,
    );
    if (confirmed == true && mounted) {
      setState(() => _state().apply());
      showPermissionToast(context, '已保存 $_role 的权限');
    }
  }

  void _cancel() {
    setState(() => _state().revert());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    final state = _state();
    final modules = _filter == '所有权限'
        ? _scopeModules
        : [
            for (final module in _scopeModules)
              if (module == _filter) module,
          ];
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '角色',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.xs),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: '搜索角色',
                      prefixIcon: Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: RuQiSpacing.xs,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.sm),
                  for (final role in _permissionRoles)
                    _RoleItem(
                      label: role,
                      selected: role == _role,
                      onTap: () => setState(() {
                        _role = role;
                        _filter = '所有权限';
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(width: RuQiSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '角色权限',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: RuQiSpacing.xs),
                        child: Text(
                          '名称：$_role · 成员：2 · 最后编辑 account001 · 3/29/2022 10:04:32',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RuQiSpacing.md),
                  if (state.modified) ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        RuQiSpacing.md,
                        RuQiSpacing.xs,
                        RuQiSpacing.xs,
                        RuQiSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color:
                            ext?.warning.withValues(alpha: 0.12) ??
                            theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: ext?.warning ?? theme.colorScheme.error,
                          ),
                          const SizedBox(width: RuQiSpacing.xs),
                          Text(
                            '权限被修改',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ext?.warning ?? theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _cancel,
                            style: RuQiButtonStyles.tertiary(context),
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: RuQiSpacing.xs),
                          FilledButton(
                            onPressed: _save,
                            style: RuQiButtonStyles.primary(context),
                            child: const Text('保存修改'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: RuQiSpacing.md),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        for (final scope in _permissionScopes)
                          ButtonSegment(value: scope, label: Text(scope)),
                      ],
                      selected: {_scope},
                      onSelectionChanged: (selection) => setState(() {
                        _scope = selection.first;
                        _filter = '所有权限';
                      }),
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.md),
                  Wrap(
                    spacing: RuQiSpacing.xs,
                    runSpacing: RuQiSpacing.xs,
                    children: [
                      for (final option in ['所有权限', ..._scopeModules])
                        ChoiceChip(
                          label: Text(option),
                          selected: _filter == option,
                          onSelected: (_) => setState(() => _filter = option),
                        ),
                    ],
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
                              Expanded(
                                flex: 16,
                                child: UserColumnHeader('一级菜单'),
                              ),
                              Expanded(
                                flex: 14,
                                child: UserColumnHeader('二级菜单'),
                              ),
                              Expanded(
                                flex: 14,
                                child: UserColumnHeader('页面名称'),
                              ),
                              Expanded(flex: 8, child: UserColumnHeader('查看')),
                              Expanded(flex: 8, child: UserColumnHeader('编辑')),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        for (final (moduleIndex, module) in modules.indexed)
                          for (final (subIndex, submenu) in _submenusOf(
                            module,
                          ).indexed)
                            _PermissionRow(
                              module: module,
                              submenu: submenu,
                              showModule: subIndex == 0,
                              showDivider:
                                  moduleIndex != modules.length - 1 ||
                                  subIndex != _submenusOf(module).length - 1,
                              view: state.view.contains('$module/$submenu'),
                              edit: state.edit.contains('$module/$submenu'),
                              onViewChanged: (value) => setState(() {
                                final key = '$module/$submenu';
                                value == true
                                    ? state.view.add(key)
                                    : state.view.remove(key);
                              }),
                              onEditChanged: (value) => setState(() {
                                final key = '$module/$submenu';
                                value == true
                                    ? state.edit.add(key)
                                    : state.edit.remove(key);
                              }),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.sm),
                  Text(
                    '勾选「查看 / 编辑」控制该角色可访问的菜单与可执行的操作，'
                    '保存后对组内所有成员生效。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 左侧角色列表项。
class _RoleItem extends StatelessWidget {
  const _RoleItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RuQiSpacing.sm,
          vertical: RuQiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            UserAvatar(label: label.characters.first, size: 24),
            const SizedBox(width: RuQiSpacing.sm),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 权限矩阵行：一级菜单（首行展示）/ 二级菜单 / 页面名称 + 查看 / 编辑。
class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.module,
    required this.submenu,
    required this.showModule,
    required this.showDivider,
    required this.view,
    required this.edit,
    required this.onViewChanged,
    required this.onEditChanged,
  });

  final String module;
  final String submenu;
  final bool showModule;
  final bool showDivider;
  final bool view;
  final bool edit;
  final ValueChanged<bool?> onViewChanged;
  final ValueChanged<bool?> onEditChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.lg,
        vertical: RuQiSpacing.xs,
      ),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            flex: 16,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                showModule ? module : '',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                submenu,
                overflow: TextOverflow.ellipsis,
                style: cellStyle,
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                submenu,
                overflow: TextOverflow.ellipsis,
                style: cellStyle,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Checkbox(
              value: view,
              onChanged: onViewChanged,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            flex: 8,
            child: Checkbox(
              value: edit,
              onChanged: onEditChanged,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
