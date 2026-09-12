import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

/// 基础-导入地区 业务正文（对应 导入地区 原型）。
class ImportRegionsBody extends StatelessWidget {
  const ImportRegionsBody({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '导入地区',
          description: '通过系统模板批量导入地区与国家资料。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionLabel('导入模板下载'),
                const SizedBox(height: RuQiSpacing.xs),
                OutlinedButton.icon(
                  style: RuQiButtonStyles.secondary(context),
                  onPressed: () =>
                      _showSnack(context, '已开始下载系统模板（演示）'),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('下载系统模板'),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const _SectionLabel('选择地区文件'),
                const SizedBox(height: RuQiSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(RuQiSpacing.lg),
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
                        Icons.upload_file_outlined,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: RuQiSpacing.sm),
                      OutlinedButton(
                        style: RuQiButtonStyles.secondary(context),
                        onPressed: () =>
                            _showSnack(context, '请选择要导入的地区文件（演示）'),
                        child: const Text('上传文件'),
                      ),
                      const SizedBox(height: RuQiSpacing.xs),
                      Text(
                        '支持扩展:  .xls  .xlsx .json ，文件最大支持100M',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.md,
                    vertical: RuQiSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 18),
                      const SizedBox(width: RuQiSpacing.sm),
                      const Expanded(child: CellText('single_zh-CN1666161231788.xlsx')),
                      TextButton(
                        style: RuQiButtonStyles.tertiary(context),
                        onPressed: () {},
                        child: const Text('移除'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: RuQiButtonStyles.primary(context),
                    onPressed: () => _showSnack(context, '导入任务已创建（演示）'),
                    child: const Text('确认导入'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.md),
        Container(
          padding: const EdgeInsets.all(RuQiSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: ext?.info ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: RuQiSpacing.sm),
              Expanded(
                child: Text(
                  '温馨提示：坐标文件需要 json 格式导入；模板中的必填列缺失时，'
                  '导入任务会失败并给出逐行错误提示。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
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
