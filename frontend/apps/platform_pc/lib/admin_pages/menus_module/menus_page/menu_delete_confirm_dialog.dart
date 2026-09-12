import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'menu_models.dart';

/// 菜单删除确认对话框。
Future<bool?> showMenuDeleteConfirm(BuildContext context, MenuItem item) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除菜单'),
        content: Text('确定删除菜单「${item.name}」吗？删除后其下级菜单将一并隐藏。'),
        actions: [
          TextButton(
            style: RuQiButtonStyles.tertiary(context),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: RuQiButtonStyles.danger(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('删除'),
          ),
        ],
      );
    },
  );
}
