import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'geo_models.dart';

/// 打开大洲 / 大洋编辑面板。
Future<void> showGeoPlateEditPanel(BuildContext context, GeoPlate plate) {
  return showSystemSettingsPanel(
    context,
    title: '编辑 ${plate.zhName}',
    child: GeoPlateEditForm(plate: plate),
  );
}

/// 大洲 / 大洋编辑表单：代号 / 基本语名称 / 英文简称。
class GeoPlateEditForm extends StatefulWidget {
  const GeoPlateEditForm({super.key, required this.plate});

  final GeoPlate plate;

  @override
  State<GeoPlateEditForm> createState() => _GeoPlateEditFormState();
}

class _GeoPlateEditFormState extends State<GeoPlateEditForm> {
  late final TextEditingController _code;
  late final TextEditingController _zhName;
  late final TextEditingController _enName;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.plate.code);
    _zhName = TextEditingController(text: widget.plate.zhName);
    _enName = TextEditingController(text: widget.plate.enName);
  }

  @override
  void dispose() {
    _code.dispose();
    _zhName.dispose();
    _enName.dispose();
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
                  controller: _code,
                  decoration: const InputDecoration(labelText: '代号'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _zhName,
                  decoration: const InputDecoration(labelText: '大洲(基本语)名称'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _enName,
                  decoration: const InputDecoration(labelText: '英文简称'),
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
