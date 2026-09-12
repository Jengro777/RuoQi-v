import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

/// 打开创建角色组面板。
Future<void> showCreateRolePanel(BuildContext context) {
  return showSystemSettingsPanel(
    context,
    title: '创建角色',
    child: const CreateRoleForm(),
  );
}

/// 创建角色组表单：角色名称 / 名称 / 备注信息。
class CreateRoleForm extends StatefulWidget {
  const CreateRoleForm({super.key});

  @override
  State<CreateRoleForm> createState() => _CreateRoleFormState();
}

class _CreateRoleFormState extends State<CreateRoleForm> {
  final _name = TextEditingController();
  final _initial = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _initial.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  decoration: const InputDecoration(
                    labelText: '角色名称',
                    helperText: '如 实施经理、运营专员。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _initial,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    helperText: '列表中展示的简称，如 实 / 运。',
                  ),
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
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '创建', onConfirm: () => Navigator.of(context).pop()),
      ],
    );
  }
}
