import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 菜单操作结果轻提示（toast）。
void showMenuToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
