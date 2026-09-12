import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 通用确认对话框（内容区上方小弹窗，保留遮罩）。
Future<bool> showUserConfirmDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        title: Text(
          title,
          style: zh(
            theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        content: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: RuQiButtonStyles.tertiary(context),
            child: const Text('取消'),
          ),
          const SizedBox(width: RuQiSpacing.xs),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? RuQiButtonStyles.danger(context)
                : RuQiButtonStyles.primary(context),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
