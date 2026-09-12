import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 货币操作结果轻提示（toast）。
void showCurrencyToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
