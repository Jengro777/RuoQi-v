import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'language_models.dart';

/// 打开语言新增 / 编辑面板。
Future<void> showLanguageEditPanel(
  BuildContext context, {
  Language? language,
}) {
  return showSystemSettingsPanel(
    context,
    title: language == null ? '添加语言' : '编辑语言',
    child: LanguageEditForm(language: language),
  );
}

/// 语言新增 / 编辑表单。
class LanguageEditForm extends StatefulWidget {
  const LanguageEditForm({super.key, this.language});

  final Language? language;

  @override
  State<LanguageEditForm> createState() => _LanguageEditFormState();
}

class _LanguageEditFormState extends State<LanguageEditForm> {
  late final TextEditingController _code;
  late final TextEditingController _code2;
  late final TextEditingController _code3;
  late final TextEditingController _nativeName;
  late final TextEditingController _sort;
  bool _isBase = false;

  @override
  void initState() {
    super.initState();
    final language = widget.language;
    _code = TextEditingController(text: language?.code ?? '');
    _code2 = TextEditingController(text: language?.code2 ?? '');
    _code3 = TextEditingController(text: language?.code3 ?? '');
    _nativeName = TextEditingController(text: language?.nativeName ?? '');
    _sort = TextEditingController(text: '${language?.sort ?? 1}');
    _isBase = language?.isBase ?? false;
  }

  @override
  void dispose() {
    _code.dispose();
    _code2.dispose();
    _code3.dispose();
    _nativeName.dispose();
    _sort.dispose();
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
                  decoration: const InputDecoration(
                    labelText: '*语言代码',
                    hintText: '如 zh_CN',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code2,
                        decoration: const InputDecoration(
                          labelText: '两字母代码',
                          hintText: '如 zh',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _code3,
                        decoration: const InputDecoration(
                          labelText: '三字母代码',
                          hintText: '如 zho',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _nativeName,
                  decoration: const InputDecoration(
                    labelText: '语言自称',
                    hintText: '如 简体中文-中国大陆',
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
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                SwitchListTile(
                  value: _isBase,
                  onChanged: (v) => setState(() => _isBase = v),
                  title: const Text('设为基本语言'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.language == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
