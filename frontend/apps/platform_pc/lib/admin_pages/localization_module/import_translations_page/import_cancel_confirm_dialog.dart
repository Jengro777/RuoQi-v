import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 取消导入确认对话框。
Future<bool?> showImportCancelConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('取消导入'),
        content: const Text('确定取消本次翻译导入吗？已上传的文件将被移除。'),
        actions: [
          TextButton(
            style: RuQiButtonStyles.tertiary(context),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('关闭'),
          ),
          FilledButton(
            style: RuQiButtonStyles.danger(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('取消导入'),
          ),
        ],
      );
    },
  );
}
