import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 批量导入。
class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Scaffold(
      appBar: AppBar(title: const Text('导入')),
      body: ListView(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: RuQiSpacing.sm),
                Text('拖拽文件到此处，或点击选择', style: theme.textTheme.bodyMedium),
                const SizedBox(height: RuQiSpacing.xs),
                Text(
                  '支持 CSV / XLSX，最大 10MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RuQiSpacing.lg),
          FilledButton(
            onPressed: () {},
            style: RuQiButtonStyles.primary(context),
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }
}
