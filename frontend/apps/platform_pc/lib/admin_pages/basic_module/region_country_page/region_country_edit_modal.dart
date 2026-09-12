import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'region_country_models.dart';

/// 打开地区新增 / 编辑面板。
Future<void> showRegionCountryEditPanel(
  BuildContext context, {
  RegionCountry? region,
}) {
  return showSystemSettingsPanel(
    context,
    title: region == null ? '添加地区' : '编辑地区',
    child: RegionCountryEditForm(region: region),
  );
}

/// 地区新增 / 编辑表单。
class RegionCountryEditForm extends StatefulWidget {
  const RegionCountryEditForm({super.key, this.region});

  final RegionCountry? region;

  @override
  State<RegionCountryEditForm> createState() => _RegionCountryEditFormState();
}

class _RegionCountryEditFormState extends State<RegionCountryEditForm> {
  late final TextEditingController _zhName;
  late final TextEditingController _code2;
  late final TextEditingController _code3;
  late final TextEditingController _codeNum;
  late final TextEditingController _dialCode;
  late final TextEditingController _continent;
  late final TextEditingController _localCode;
  late final TextEditingController _postalCode;

  @override
  void initState() {
    super.initState();
    final region = widget.region;
    _zhName = TextEditingController(text: region?.zhName ?? '');
    _code2 = TextEditingController(text: region?.code2 ?? '');
    _code3 = TextEditingController(text: region?.code3 ?? '');
    _codeNum = TextEditingController(text: region?.codeNum ?? '');
    _dialCode = TextEditingController(text: region?.dialCode ?? '');
    _continent = TextEditingController(text: region?.continent ?? '');
    _localCode = TextEditingController(text: region?.localCode ?? '');
    _postalCode = TextEditingController();
  }

  @override
  void dispose() {
    _zhName.dispose();
    _code2.dispose();
    _code3.dispose();
    _codeNum.dispose();
    _dialCode.dispose();
    _continent.dispose();
    _localCode.dispose();
    _postalCode.dispose();
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
                  controller: _zhName,
                  decoration: const InputDecoration(
                    labelText: '*地区名称',
                    hintText: '如 中国',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _localCode,
                  decoration: const InputDecoration(
                    labelText: '地区&国家简称(i18n)',
                    hintText: '如 zh-CN',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code2,
                        decoration: const InputDecoration(
                          labelText: '*两字母代码',
                          hintText: '如 CN',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _code3,
                        decoration: const InputDecoration(
                          labelText: '*三字母代码',
                          hintText: '如 CHN',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeNum,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '*数字代码',
                          hintText: '如 156',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _dialCode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '国际冠码',
                          hintText: '如 86',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _continent,
                        decoration: const InputDecoration(
                          labelText: '大洲代码',
                          hintText: '如 AS1',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _postalCode,
                        decoration: const InputDecoration(
                          labelText: '国际邮编',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.region == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
