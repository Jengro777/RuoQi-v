import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'translation_edit_modal.dart';
import 'translation_history_modal.dart';
import 'translation_models.dart';
import 'translation_toast.dart';

/// 语言-翻译 业务正文（对应 翻译 原型）。
class TranslationsBody extends StatefulWidget {
  const TranslationsBody({super.key});

  @override
  State<TranslationsBody> createState() => _TranslationsBodyState();
}

class _TranslationsBodyState extends State<TranslationsBody> {
  String _query = '';

  List<TranslationKey> get _filtered {
    final q = _query.trim();
      return [
      for (final item in translationKeys)
        if (q.isEmpty || item.key.toLowerCase().contains(q.toLowerCase()))
          item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '翻译',
          description: '维护各语言下的文案翻译。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Filter...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: RuQiSpacing.md),
            TextButton(
              style: RuQiButtonStyles.tertiary(context),
              onPressed: () {},
              child: const Text('未翻译'),
            ),
            TextButton(
              style: RuQiButtonStyles.tertiary(context),
              onPressed: () {},
              child: Text(
                '已翻译',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'Keys', flex: 20),
            (label: '简体中文', flex: 18),
            (label: 'English', flex: 18),
            (label: '状态', flex: 8),
            (label: '操作', flex: 18),
          ],
          rowCount: _filtered.length,
          emptyText: '无匹配翻译',
          rowBuilder: (context, index) {
            final item = _filtered[index];
            return [
              CellText(item.key, strong: true),
              CellText(item.zh.isEmpty ? '--' : item.zh),
              CellText(item.en.isEmpty ? '--' : item.en, muted: true),
              StatusBadge(
                label: item.translated ? '已翻译' : '未翻译',
                tone: item.translated ? StatusTone.success : StatusTone.warning,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => showTranslationEditPanel(context, item),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => showTranslationHistoryPanel(context, item),
                    child: const Text('历史'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => showTranslationToast(context, '已标记为已读'),
                    child: const Text('标记已读'),
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
