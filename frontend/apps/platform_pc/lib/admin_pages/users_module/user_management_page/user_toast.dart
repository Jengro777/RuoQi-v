import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 用户操作结果轻提示（toast）。
void showUserToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
