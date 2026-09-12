import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'utc_zone_models.dart';

/// 打开时区编辑面板。
Future<void> showUtcZoneEditPanel(BuildContext context, UtcZoneRow row) {
  return showSystemSettingsPanel(
    context,
    title: '编辑 ${row.label}',
    child: UtcZoneEditForm(row: row),
  );
}

/// 时区编辑表单。
class UtcZoneEditForm extends StatefulWidget {
  const UtcZoneEditForm({super.key, required this.row});

  final UtcZoneRow row;

  @override
  State<UtcZoneEditForm> createState() => _UtcZoneEditFormState();
}

class _UtcZoneEditFormState extends State<UtcZoneEditForm> {
  late final TextEditingController _center;
  late final TextEditingController _range;

  @override
  void initState() {
    super.initState();
    _center = TextEditingController(text: widget.row.center);
    _range = TextEditingController(text: widget.row.range);
  }

  @override
  void dispose() {
    _center.dispose();
    _range.dispose();
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
                Text(
                  '时区 ID：${widget.row.id}（${widget.row.label}）',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _center,
                  decoration: const InputDecoration(labelText: '时区中心线'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _range,
                  decoration: const InputDecoration(labelText: '经度范围'),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
