import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 地区&国家操作结果轻提示（toast）。
void showRegionCountryToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: RuQiMotion.normal),
  );
}
