import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 保存权限确认对话框。
Future<bool?> showPermissionSaveConfirm(
  BuildContext context, {
  required String role,
  required int added,
  required int removed,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        title: const Text('保存权限？'),
        content: Text(
          '「$role」将新增 $added 个权限，取消 $removed 个权限。\n'
          '你确定要保存修改吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: RuQiButtonStyles.tertiary(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: RuQiButtonStyles.primary(dialogContext),
            child: const Text('是'),
          ),
        ],
      );
    },
  );
}
