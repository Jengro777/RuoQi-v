import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

/// 语言-导出 业务正文（对应 导出 原型）。
class ExportTranslationsBody extends StatefulWidget {
  const ExportTranslationsBody({super.key});

  @override
  State<ExportTranslationsBody> createState() => _ExportTranslationsBodyState();
}

class _ExportTranslationsBodyState extends State<ExportTranslationsBody> {
  final Set<String> _selected = {'zh_CN', 'en_US', 'fr_FR'};

  static const _languages = [
    ('zh_CN', '简体中文-中国大陆'),
    ('en_US', 'English(US)'),
    ('fr_FR', 'Français'),
    ('pt-PT', 'português'),
    ('ru-RU', 'русский (Россия)'),
    ('VN-VI', 'Tiếng Việt'),
  ];

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '导出',
          description: '按格式导出指定语言的翻译文件。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionLabel('格式'),
                const SizedBox(height: RuQiSpacing.xs),
                Row(
                  children: [
                    for (final format in const ['JSON', 'XLIFF', 'PO'])
                      Padding(
                        padding: const EdgeInsets.only(right: RuQiSpacing.md),
                        child: ChoiceChip(
                          label: Text(format),
                          selected: format == 'JSON',
                          onSelected: (_) =>
                              _showSnack(context, '已选择 $format 格式'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const _SectionLabel('选择语言'),
                const SizedBox(height: RuQiSpacing.xs),
                CheckboxListTile(
                  value: _selected.length == _languages.length,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.addAll([for (final l in _languages) l.$1]);
                    } else {
                      _selected.clear();
                    }
                  }),
                  title: const Text('全部语言'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 1),
                for (final (code, name) in _languages)
                  CheckboxListTile(
                    value: _selected.contains(code),
                    onChanged: (v) => setState(() {
                      v == true ? _selected.add(code) : _selected.remove(code);
                    }),
                    title: Text(name),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: RuQiSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: RuQiButtonStyles.primary(context),
                    onPressed: () => _showSnack(
                      context,
                      '已导出 ${_selected.length} 个语言的翻译文件（演示）',
                    ),
                    child: const Text('导出'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
