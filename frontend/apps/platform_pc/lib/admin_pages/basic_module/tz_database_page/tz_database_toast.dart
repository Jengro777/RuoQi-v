import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 时区数据库操作结果轻提示（toast）。
void showTzDatabaseToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
