import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'region_country_models.dart';

/// 地区删除确认对话框。
Future<bool?> showRegionDeleteConfirm(
  BuildContext context,
  RegionCountry region,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除地区'),
        content: Text('确定删除地区「${region.zhName}」吗？删除后不可恢复。'),
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
