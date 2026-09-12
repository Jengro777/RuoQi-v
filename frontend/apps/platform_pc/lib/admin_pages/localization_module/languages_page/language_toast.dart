import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 多语言操作结果轻提示（toast）。
void showLanguageToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
