import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// 权限操作结果轻提示（toast）。
void showPermissionToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
