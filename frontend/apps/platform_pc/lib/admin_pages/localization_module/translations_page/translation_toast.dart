import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 翻译操作结果轻提示（toast）。
void showTranslationToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
