import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';

import 'translation_models.dart';

/// 打开翻译历史面板。
Future<void> showTranslationHistoryPanel(
  BuildContext context,
  TranslationKey item,
) {
  return showSystemSettingsPanel(
    context,
    title: '${item.key} 历史',
    child: const TranslationHistoryForm(),
  );
}

/// 翻译历史：版本列表。
class TranslationHistoryForm extends StatelessWidget {
  const TranslationHistoryForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        for (final revision in const [
          ('12/12/2022 08:05', '已翻译 · account1', '简体中文：评价时间'),
          ('12/11/2022 18:20', '已翻译 · account2', '简体中文：评价 时间'),
          ('12/10/2022 09:40', '已创建 · account1', '简体中文：--'),
        ]) ...[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(RuQiSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          revision.$1,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.xxs),
                        Text(
                          revision.$2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.xxs),
                        Text(
                          revision.$3,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
        ],
      ],
    );
  }
}
