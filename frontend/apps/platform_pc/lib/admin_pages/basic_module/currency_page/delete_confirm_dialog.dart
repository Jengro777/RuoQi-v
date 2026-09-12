import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'currency_models.dart';

/// 货币删除确认对话框。
Future<bool?> showCurrencyDeleteConfirm(
  BuildContext context,
  Currency currency,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除货币'),
        content: Text('确定删除货币「${currency.zhName}（${currency.code}）」吗？'),
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
