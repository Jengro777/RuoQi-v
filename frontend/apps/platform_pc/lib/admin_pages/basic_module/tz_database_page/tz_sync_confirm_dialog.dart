import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 同步时区数据库确认对话框。
Future<bool?> showTzDatabaseSyncConfirm(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('同步时区数据库'),
        content: const Text(
          '将拉取 IANA 最新时区数据并覆盖当前列表，确定同步吗？',
        ),
        actions: [
          TextButton(
            style: RuQiButtonStyles.tertiary(context),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: RuQiButtonStyles.primary(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('同步'),
          ),
        ],
      );
    },
  );
}
