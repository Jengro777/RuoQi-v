import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'language_delete_confirm_dialog.dart';
import 'language_edit_modal.dart';
import 'language_models.dart';
import 'language_toast.dart';

/// 语言-多语言 业务正文（对应 多语言 原型）。
class LanguagesBody extends StatelessWidget {
  const LanguagesBody({super.key});

  Future<void> _handleAction(
    BuildContext context,
    Language language,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showLanguageEditPanel(context, language: language);
      case '启用':
        showLanguageToast(context, '已启用 ${language.nativeName}');
      case '停用':
        showLanguageToast(context, '已停用 ${language.nativeName}');
      case '删除':
        final confirmed = await showLanguageDeleteConfirm(context, language);
        if (confirmed == true && context.mounted) {
          showLanguageToast(context, '已删除 ${language.nativeName}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '多语言',
          description: '维护平台支持的界面语言与录入状态。',
          actionLabel: '添加',
          onAction: () => showLanguageEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '语言代码', flex: 10),
            (label: '两字母代码', flex: 8),
            (label: '三字母代码', flex: 8),
            (label: '语言自称', flex: 16),
            (label: '排序', flex: 6),
            (label: '基本语言', flex: 8),
            (label: '状态', flex: 7),
            (label: '操作', flex: 20),
          ],
          rowCount: languages.length,
          rowBuilder: (context, index) {
            final language = languages[index];
            return [
              CellText(language.code, strong: true),
              CellText(language.code2, muted: true),
              CellText(language.code3, muted: true),
              CellText(language.nativeName),
              CellText('${language.sort}', muted: true),
              Text(
                language.isBase ? '是' : '否',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: language.isBase
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: language.isBase ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              StatusBadge(
                label: language.enabled ? '启用中' : '已停用',
                tone: language.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, language, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      language,
                      language.enabled ? '停用' : '启用',
                    ),
                    child: Text(language.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, language, '删除'),
                    child: Text(
                      '删除',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      ],
    );
  }
}
