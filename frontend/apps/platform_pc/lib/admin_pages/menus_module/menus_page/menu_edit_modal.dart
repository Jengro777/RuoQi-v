import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'menu_models.dart';

/// 打开菜单新增 / 编辑面板。
Future<void> showMenuEditPanel(
  BuildContext context, {
  MenuItem? item,
  String? parent,
}) {
  return showSystemSettingsPanel(
    context,
    title: item == null ? '添加菜单' : '编辑菜单',
    child: MenuEditForm(item: item, parent: parent),
  );
}

/// 菜单新增 / 编辑表单。
class MenuEditForm extends StatefulWidget {
  const MenuEditForm({super.key, this.item, this.parent});

  final MenuItem? item;
  final String? parent;

  @override
  State<MenuEditForm> createState() => _MenuEditFormState();
}

class _MenuEditFormState extends State<MenuEditForm> {
  late final TextEditingController _name;
  late final TextEditingController _permissionKey;
  late final TextEditingController _sort;
  late final TextEditingController _icon;
  late final TextEditingController _url;
  late final TextEditingController _componentPath;
  late String _parent;
  late String _type;
  late String _openMode;
  bool _hidden = false;
  bool _single = false;

  static const _parents = ['根目录', '设置', '用户', '权限', '菜单', '基础', '语言', '日志'];
  static const _types = ['顶菜单', '左菜单', '按钮'];
  static const _openModes = ['内部URL', '外部URL', '内联框架', '新开页签'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _permissionKey = TextEditingController(text: item?.permissionKey ?? '');
    _sort = TextEditingController(text: '${item?.sort ?? 1}');
    _icon = TextEditingController(text: item?.icon ?? '');
    _url = TextEditingController(text: item?.url ?? '');
    _componentPath = TextEditingController(text: item?.componentPath ?? '');
    _parent = widget.parent ?? item?.parent ?? '根目录';
    _type = item?.type ?? '左菜单';
    _openMode = '内部URL';
  }

  @override
  void dispose() {
    _name.dispose();
    _permissionKey.dispose();
    _sort.dispose();
    _icon.dispose();
    _url.dispose();
    _componentPath.dispose();
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
                    labelText: '*菜单名称',
                    hintText: '菜单名称',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: '*上级区域',
                        value: _parent,
                        options: _parents,
                        onChanged: (v) => setState(() => _parent = v!),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: _DropdownField(
                        label: '*类型',
                        value: _type,
                        options: _types,
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _permissionKey,
                  decoration: const InputDecoration(
                    labelText: '*权限标识',
                    hintText: '如 base:timezone',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sort,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '排序'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _icon,
                        decoration: const InputDecoration(
                          labelText: '图标',
                          hintText: '点击选择 / 上传',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        value: _hidden,
                        onChanged: (v) => setState(() => _hidden = v),
                        title: const Text('是否隐藏'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        value: _single,
                        onChanged: (v) => setState(() => _single = v),
                        title: const Text('是否单个'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                TextField(
                  controller: _url,
                  decoration: const InputDecoration(
                    labelText: '*网页URL',
                    hintText: 'URL',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                _DropdownField(
                  label: '打开方式',
                  value: _openMode,
                  options: _openModes,
                  onChanged: (v) => setState(() => _openMode = v!),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _componentPath,
                  decoration: const InputDecoration(
                    labelText: '*组件路径',
                    hintText: '如 /base/timezone',
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.item == null ? '添加' : '保存',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// 下拉字段。
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: onChanged,
    );
  }
}
