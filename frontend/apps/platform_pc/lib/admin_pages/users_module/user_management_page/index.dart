import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'deactivate_confirm_dialog.dart';
import 'edit_user_modal.dart';
import 'invite_user_modal.dart';
import 'password_reset_url_modal.dart';
import 'reactivate_confirm_dialog.dart';
import 'temporary_password_reset_flow_modal.dart';
import 'user_toast.dart';

/// 管理后台-用户 业务正文（对应 用户(活跃) / 用户(已停用) 原型）。
///
/// 按 DESIGN-consensus.md 规范实现：
/// - 页头 + 邀请主按钮（§6.1 button-primary）；
/// - 搜索 / 状态筛选 / 角色筛选；
/// - 表格：`surfaceContainerHigh` 表头 + `outlineVariant` 分隔线；
/// - 行操作以弹层面板 / 确认对话框打开（§6.9）。
class UsersBody extends StatefulWidget {
  const UsersBody({super.key});

  @override
  State<UsersBody> createState() => _UsersBodyState();
}

enum _StatusFilter { all, active, deactivated }

class _UsersBodyState extends State<UsersBody> {
  String _query = '';
  _StatusFilter _status = _StatusFilter.all;
  String _role = '所有角色';

  /// 可编辑的用户列表（角色列弹窗修改会更新这里）。
  late final List<UserAccount> _users = List.of(userAccounts);

  List<UserAccount> get _filtered {
    final query = _query.trim().toLowerCase();
    return _users.where((user) {
      final matchQuery =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.account.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.toLowerCase().contains(query);
      final matchStatus = switch (_status) {
        _StatusFilter.all => true,
        _StatusFilter.active => user.status == UserStatus.active,
        _StatusFilter.deactivated => user.status == UserStatus.deactivated,
      };
      final matchRole =
          _role == '所有角色' || user.roles.contains(_role) || _role == '自定义角色';
      return matchQuery && matchStatus && matchRole;
    }).toList();
  }

  void _handleRolesChanged(UserAccount user, List<String> roles) {
    setState(() {
      final index = _users.indexOf(user);
      if (index != -1) _users[index] = user.copyWith(roles: roles);
    });
  }

  Future<void> _handleAction(UserAccount user, String action) async {
    switch (action) {
      case '编辑用户':
        await showEditUserPanel(context, user);
      case '复制密码重置链接':
        await showPasswordResetUrlPanel(context, user);
      case '重置密码':
        await showTemporaryPasswordResetFlow(context, user);
      case '停用用户':
        final confirmed = await showDeactivateConfirmDialog(context, user);
        if (confirmed && mounted) showUserToast(context, '已停用 ${user.displayName}');
      case '重新发送邀请电子邮件':
        showUserToast(context, '邀请邮件已重新发送至 ${user.email}');
      case '复制邀请链接':
        showUserToast(context, '邀请链接已复制');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final users = _filtered;
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '用户',
          description: '管理控制台用户账号、角色与登录状态。',
          actionLabel: '邀请用户',
          onAction: () => showInviteUserPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: '名称/账号/邮件/手机号',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.xs,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: RuQiSpacing.md),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                initialValue: _role,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.sm,
                    vertical: 8,
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: '所有角色', child: Text('所有角色')),
                  for (final role in roleGroups)
                    DropdownMenuItem(value: role.name, child: Text(role.name)),
                  const DropdownMenuItem(value: '自定义角色', child: Text('自定义角色')),
                ],
                onChanged: (value) => setState(() => _role = value ?? '所有角色'),
              ),
            ),
            const SizedBox(width: RuQiSpacing.md),
            for (final status in _StatusFilter.values)
              Padding(
                padding: const EdgeInsets.only(right: RuQiSpacing.xs),
                child: ChoiceChip(
                  label: Text(_filterLabel(status)),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status),
                ),
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
                    Expanded(flex: 22, child: UserColumnHeader('名称')),
                    Expanded(flex: 14, child: UserColumnHeader('账号')),
                    Expanded(flex: 16, child: UserColumnHeader('电子邮件')),
                    Expanded(flex: 15, child: UserColumnHeader('手机号')),
                    Expanded(flex: 16, child: UserColumnHeader('角色')),
                    Expanded(flex: 10, child: UserColumnHeader('最后一次登录')),
                    Expanded(flex: 9, child: UserColumnHeader('操作')),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (users.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(RuQiSpacing.xl),
                  child: Text(
                    '无匹配用户',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final (index, user) in users.indexed)
                  _UserRow(
                    user: user,
                    showDivider: index != users.length - 1,
                    onRolesChanged: (roles) => _handleRolesChanged(user, roles),
                    onAction: (action) => _handleAction(user, action),
                    onReactivate: () async {
                      final confirmed = await showReactivateConfirmDialog(
                        context,
                        user,
                      );
                      if (confirmed && context.mounted) {
                        showUserToast(context, '已重新激活 ${user.displayName}');
                      }
                    },
                  ),
            ],
          ),
        ),
        const SizedBox(height: RuQiSpacing.sm),
        UserPagination(total: users.length, pageSize: 10),
      ],
    );
  }

  String _filterLabel(_StatusFilter status) => switch (status) {
    _StatusFilter.all => '所有用户',
    _StatusFilter.active => '活跃',
    _StatusFilter.deactivated => '已停用',
  };
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.showDivider,
    required this.onRolesChanged,
    required this.onAction,
    required this.onReactivate,
  });

  final UserAccount user;
  final bool showDivider;
  final ValueChanged<List<String>> onRolesChanged;
  final ValueChanged<String> onAction;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deactivated = user.status == UserStatus.deactivated;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.lg,
        vertical: RuQiSpacing.sm,
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
            flex: 22,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Row(
                children: [
                  UserAvatar(label: user.name.characters.first.toUpperCase()),
                  const SizedBox(width: RuQiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (deactivated) ...[
                          const SizedBox(height: RuQiSpacing.xxs),
                          const UserStatusBadge(deactivated: true),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                user.account,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                user.email,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                user.phone,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: _RoleCell(
                roles: user.roles,
                onRolesChanged: onRolesChanged,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.only(right: RuQiSpacing.sm),
              child: Text(
                user.lastLogin,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Align(
              alignment: Alignment.centerLeft,
              child: deactivated
                  ? OutlinedButton(
                      onPressed: onReactivate,
                      style: RuQiButtonStyles.secondary(context),
                      child: const Text('恢复'),
                    )
                  : _UserActionsMenu(user: user, onAction: onAction),
            ),
          ),
        ],
      ),
    );
  }
}

/// 角色列：点击弹出一个跟随单元格的小菜单，勾选 / 取消勾选角色组。
/// 菜单顶部是默认角色（默认选中且不可取消），下方是 `自定义角色` 分区，
/// 支持按名称搜索过滤角色。
class _RoleCell extends StatefulWidget {
  const _RoleCell({required this.roles, required this.onRolesChanged});

  final List<String> roles;
  final ValueChanged<List<String>> onRolesChanged;

  @override
  State<_RoleCell> createState() => _RoleCellState();
}

class _RoleCellState extends State<_RoleCell> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(String role, bool checked) {
    widget.onRolesChanged(
      checked
          ? [...widget.roles, role]
          : [...widget.roles.where((r) => r != role)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaults = roleGroups.where((group) => group.isDefault).toList();
    final defaultNames = defaults.map((group) => group.name).toSet();
    final query = _query.trim().toLowerCase();
    final customRoles = <String>{
      for (final group in roleGroups)
        if (!group.isDefault) group.name,
      for (final role in widget.roles)
        if (!defaultNames.contains(role)) role,
    }.where((role) => role.toLowerCase().contains(query)).toList();
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainerLow,
        ),
        elevation: WidgetStatePropertyAll(6),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) => InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            _searchController.clear();
            setState(() => _query = '');
            controller.open();
          }
        },
        child: child,
      ),
      menuChildren: [
        for (final group in defaults)
          CheckboxMenuButton(
            value: group.name == '所有用户' || widget.roles.contains(group.name),
            onChanged: group.name == '所有用户'
                ? null
                : (checked) => _toggle(group.name, checked == true),
            closeOnActivate: false,
            child: Text(group.name),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '自定义角色',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: SizedBox(
            width: 240,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: '搜索角色',
                prefixIcon: Icon(Icons.search, size: 16),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.xs,
                  vertical: 8,
                ),
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
        if (customRoles.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '无匹配角色',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final role in customRoles)
            CheckboxMenuButton(
              value: widget.roles.contains(role),
              closeOnActivate: false,
              onChanged: (checked) => _toggle(role, checked == true),
              child: Text(role),
            ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: RuQiSpacing.xxs,
          runSpacing: RuQiSpacing.xxs,
          children: [
            for (final role in widget.roles) _RoleChip(label: role),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// 角色胶囊标签。
class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// 行操作菜单：编辑 / 重置密码 / 停用 / 邀请相关。
class _UserActionsMenu extends StatelessWidget {
  const _UserActionsMenu({required this.user, required this.onAction});

  final UserAccount user;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ['编辑用户', '复制密码重置链接', '重置密码', '停用用户', '重新发送邀请电子邮件', '复制邀请链接'];
    return PopupMenuButton<String>(
      tooltip: '操作',
      icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurfaceVariant),
      onSelected: onAction,
      itemBuilder: (context) => [
        for (final item in items) PopupMenuItem(value: item, child: Text(item)),
      ],
    );
  }
}
