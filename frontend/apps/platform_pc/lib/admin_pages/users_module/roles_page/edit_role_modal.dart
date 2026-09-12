import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

/// 打开编辑角色组面板。
Future<void> showEditRolePanel(BuildContext context, RoleGroup role) {
  return showSystemSettingsPanel(
    context,
    title: '编辑角色',
    child: EditRoleForm(role: role),
  );
}

/// 编辑角色组表单：名称 / 备注信息 + 元信息。
class EditRoleForm extends StatefulWidget {
  const EditRoleForm({super.key, required this.role});

  final RoleGroup role;

  @override
  State<EditRoleForm> createState() => _EditRoleFormState();
}

class _EditRoleFormState extends State<EditRoleForm> {
  late final TextEditingController _name;
  late final TextEditingController _initial;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.role.name);
    _initial = TextEditingController(text: widget.role.initial);
    _note = TextEditingController(text: widget.role.note == '--' ? '' : widget.role.note);
  }

  @override
  void dispose() {
    _name.dispose();
    _initial.dispose();
    _note.dispose();
    super.dispose();
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
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: '角色名称'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _initial,
                  maxLength: 2,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                const SizedBox(height: RuQiSpacing.sm),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注信息',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const Divider(height: 1),
                const SizedBox(height: RuQiSpacing.md),
                _MetaRow(
                  label: '创建',
                  value: 'system · 3/29/2022 10:04:32',
                  theme: theme,
                ),
                const SizedBox(height: RuQiSpacing.xs),
                _MetaRow(label: '最后编辑', value: 'account001', theme: theme),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '更新', onConfirm: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
