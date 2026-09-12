import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'import_cancel_confirm_dialog.dart';
import 'import_translation_toast.dart';

/// 语言-导入 业务正文（对应 导入 原型）。
class ImportTranslationsBody extends StatelessWidget {
  const ImportTranslationsBody({super.key});

  Future<void> _cancelImport(BuildContext context) async {
    final confirmed = await showImportCancelConfirmDialog(context);
    if (confirmed == true && context.mounted) {
      showImportTranslationToast(context, '已取消导入');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '导入',
          description: '通过翻译文件批量导入文案。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.lg,
                    vertical: RuQiSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: RuQiSpacing.sm),
                      Text(
                        'Drop file or',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: RuQiSpacing.sm),
                      FilledButton(
                        style: RuQiButtonStyles.primary(context),
                        onPressed: () => showImportTranslationToast(context, '选择翻译文件（演示）'),
                        child: const Text('SELECT FILE'),
                      ),
                      const SizedBox(height: RuQiSpacing.xs),
                      Text(
                        'support formats are  .json, .xliff, .po  max size  100M',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: 'en',
                  decoration: const InputDecoration(labelText: 'Select existing language'),
                  items: const [
                    DropdownMenuItem(value: 'zh_CN', child: Text('简体中文-中国大陆')),
                    DropdownMenuItem(value: 'en', child: Text('English(US)')),
                    DropdownMenuItem(value: 'fr_FR', child: Text('Français')),
                    DropdownMenuItem(value: 'VN-VI', child: Text('Tiếng Việt')),
                  ],
                  onChanged: (v) => showImportTranslationToast(context, '已选择语言 $v'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TableCard(
                  columns: [
                    (label: '文件名称', flex: 14),
                    (label: '翻译数量', flex: 8),
                    (label: '已解决/冲突', flex: 10),
                  ],
                  rowCount: 1,
                  rowBuilder: _fileRow,
                ),
                const SizedBox(height: RuQiSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    style: RuQiButtonStyles.secondary(context),
                    onPressed: () => _cancelImport(context),
                    child: const Text('取消导入'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<Widget> _fileRow(BuildContext context, int index) {
    return const [
      CellText('en.json', strong: true),
      CellText('10', muted: true),
      CellText('0/0', muted: true),
    ];
  }
}
