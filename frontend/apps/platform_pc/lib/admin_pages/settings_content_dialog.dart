import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 管理后台左侧菜单宽度与顶部导航栏高度（与 system_settings_dialog 布局一致）。
const systemSettingsMenuWidth = 300.0;
const systemSettingsTopBarHeight = 56.0;

/// 打开与内容区同尺寸的设置面板。
///
/// 面板覆盖在内容区之上（左侧菜单与顶部导航保持可见），
/// 与运营后台的「大面板模式」一致；返回后由 [Navigator.pop] 关闭。
///
/// 展示样式：不渲染半透明遮罩与投影阴影，面板作为内容区内嵌层
/// 从右侧滑入，仅用左侧/顶部细描边与菜单、顶栏分隔。
Future<T?> showSystemSettingsPanel<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭',
    barrierColor: Colors.transparent,
    transitionDuration: RuQiMotion.resolve(context, RuQiMotion.normal),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: RuQiMotion.resolveCurve(context, RuQiMotion.easeOut),
          ),
        ),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          Positioned(
            left: systemSettingsMenuWidth,
            top: systemSettingsTopBarHeight,
            right: 0,
            bottom: 0,
            child: SettingsContentPanel(title: title, child: child),
          ),
        ],
      );
    },
  );
}

/// 内容区尺寸的设置面板：标题条 + 可滚动正文。
class SettingsContentPanel extends StatelessWidget {
  const SettingsContentPanel({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  final String title;
  final Widget child;

  /// 自定义关闭行为；为空时直接 [Navigator.pop]。
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.only(left: RuQiSpacing.md),
              alignment: Alignment.centerLeft,
              color: theme.colorScheme.surfaceContainerLow,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                    icon: Icon(
                      Icons.close,
                      color:
                          ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
