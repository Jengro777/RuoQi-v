import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'translation_models.dart';

/// 打开翻译编辑面板。
Future<void> showTranslationEditPanel(
  BuildContext context,
  TranslationKey item,
) {
  return showSystemSettingsPanel(
    context,
    title: item.key,
    child: TranslationEditForm(item: item),
  );
}

/// 翻译编辑表单：各语言文案。
class TranslationEditForm extends StatefulWidget {
  const TranslationEditForm({super.key, required this.item});

  final TranslationKey item;

  @override
  State<TranslationEditForm> createState() => _TranslationEditFormState();
}

class _TranslationEditFormState extends State<TranslationEditForm> {
  late final TextEditingController _zh;
  late final TextEditingController _en;

  @override
  void initState() {
    super.initState();
    _zh = TextEditingController(text: widget.item.zh);
    _en = TextEditingController(text: widget.item.en);
  }

  @override
  void dispose() {
    _zh.dispose();
    _en.dispose();
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
                  'Key：${widget.item.key}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _zh,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '简体中文',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _en,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'English',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '保存',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
