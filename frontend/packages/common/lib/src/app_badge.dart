import 'package:flutter/material.dart';

/// 展示当前 App 名称与版本号的通用组件。
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.appName, required this.version});

  /// App 包名，例如 `platform`。
  final String appName;

  /// 展示用的版本号，例如 `1.0.0`。
  final String version;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        Icons.verified_outlined,
        size: 18,
        color: colorScheme.primary,
      ),
      label: Text('$appName · v$version'),
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }
}
