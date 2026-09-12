import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'language_models.dart';

/// 语言删除确认对话框。
Future<bool?> showLanguageDeleteConfirm(
  BuildContext context,
  Language language,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除语言'),
        content: Text('确定删除语言「${language.nativeName}」吗？翻译内容将一并删除。'),
        actions: [
          TextButton(
            style: RuQiButtonStyles.tertiary(context),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: RuQiButtonStyles.danger(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      );
    },
  );
}
