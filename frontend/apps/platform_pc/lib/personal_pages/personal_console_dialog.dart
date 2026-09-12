import 'package:flutter/material.dart';
import 'package:common/common.dart';

import '../appearance.dart';
import 'personal_nav.dart';
import 'personal_sidebar.dart';

/// 个人中心入口弹窗（平台端账号菜单 → 个人资料）。
///
/// 外壳与 管理后台 / 运营后台 一致：顶部 [ConsoleTopBar] + 左侧菜单 +
/// 右侧内容区；页面内的跳转（个人资料 → 账号安全 / 多因素认证 / 本地化）
/// 直接切换选中项，不再叠弹层。
class PersonalConsoleDialog {
  /// [themeMode] / [onThemeModeChanged] 与 [accent] / [onAccentChanged]
  /// 为应用外观设置，透传给「主题」页；为空时该页仅在页内预览。
  static Future<void> show(
    BuildContext context, {
    ThemeMode? themeMode,
    ValueChanged<ThemeMode>? onThemeModeChanged,
    Color? accent,
    ValueChanged<Color>? onAccentChanged,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => _PersonalConsoleDialog(
        themeMode: themeMode,
        onThemeModeChanged: onThemeModeChanged,
        accent: accent,
        onAccentChanged: onAccentChanged,
      ),
    );
  }
}

class _PersonalConsoleDialog extends StatefulWidget {
  const _PersonalConsoleDialog({
    this.themeMode,
    this.onThemeModeChanged,
    this.accent,
    this.onAccentChanged,
  });

  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final Color? accent;
  final ValueChanged<Color>? onAccentChanged;

  @override
  State<_PersonalConsoleDialog> createState() => _PersonalConsoleDialogState();
}

class _PersonalConsoleDialogState extends State<_PersonalConsoleDialog> {
  int _index = 0;

  /// 弹窗打开期间的外观取值：外壳持有当前值，切页返回时主题页仍是
  /// 最新选择（弹窗构造参数是打开那一刻的快照，会过期）。
  late ThemeMode _themeMode = widget.themeMode ?? ThemeMode.system;
  late Color _accent = widget.accent ?? defaultAccentColor;

  void _selectThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged?.call(mode);
  }

  void _selectAccent(Color accent) {
    setState(() => _accent = accent);
    widget.onAccentChanged?.call(accent);
  }

  /// 页面内跳转：切到同名菜单项。
  void _openPage(String label) {
    final index = personalNavItems.indexWhere((item) => item.label == label);
    if (index >= 0 && index != _index) {
      setState(() => _index = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = personalNavItems[_index];
    final navContext = PersonalNavContext(
      onOpenPage: _openPage,
      themeMode: _themeMode,
      onThemeModeChanged: _selectThemeMode,
      accent: _accent,
      onAccentChanged: _selectAccent,
    );
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ConsoleTopBar(
            title: '个人中心',
            onExit: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PersonalSidebar(
                  selectedIndex: _index,
                  onSelected: (index) => setState(() => _index = index),
                ),
                Expanded(
                  child: ColoredBox(
                    key: ValueKey(item.label),
                    color: Theme.of(context).colorScheme.surface,
                    child: item.builder(navContext),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
