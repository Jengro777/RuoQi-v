import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// 历史汇率操作结果轻提示（toast）。
void showRateHistoryToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
