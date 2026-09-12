// 运营后台主页面功能弹窗（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 查看 / 编辑 / 删除 / 绑定 等动作不再作为独立菜单页面，
// 而是由主页面按钮打开的动作弹窗：与主页面占用相同的空间，
// 覆盖在内容区之上（左侧菜单与顶部导航栏保持可见）。
import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 左侧菜单宽度与顶部导航栏高度（与 运营后台 弹窗布局一致）。
const _leftMenuWidth = 300.0;
const _topBarHeight = 56.0;

/// 打开主页面功能弹窗。
///
/// [child]：直接嵌入的内容（如 审核、账号安全 等业务正文）。
///
/// 传入 [size] 时以小弹窗形式展示（尺寸贴合内容，居中覆盖），
/// 不传时与主页面占用相同空间（覆盖内容区）。
Future<void> showOperationsActionDialog(
  BuildContext context, {
  required String title,
  required Widget child,
  List<Widget>? actions,
  Size? size,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭',
    barrierColor: Theme.of(context).colorScheme.scrim,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      final content = child;
      final header = _DialogHeader(
        title: title,
        actions: actions,
        onClose: () => Navigator.of(context).pop(),
      );
      if (size == null) {
        // 大面板模式：覆盖内容区（与主页面同尺寸），左侧菜单与顶栏保持可见。
        return Stack(
          children: [
            Positioned(
              left: _leftMenuWidth,
              top: _topBarHeight,
              right: 0,
              bottom: 0,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 8,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? null
                        : RuQiElevation.shadowLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      Expanded(child: content),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
      // 小弹窗模式：尺寸贴合内容，居中展示。
      // 内容自带标题（如 审核 / 审核详情），不重复渲染标题条，
      // 右上角悬浮关闭按钮。
      return Center(
        child: Stack(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(
                          context,
                        ).extension<RuQiThemeExtension>()?.hairlineStrong ??
                        Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                  boxShadow: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : RuQiElevation.shadowLg,
                ),
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: content,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                color:
                    Theme.of(
                      context,
                    ).extension<RuQiThemeExtension>()?.inkMuted ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// 弹窗标题条：标题 + 操作按钮 + 关闭按钮。
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.onClose,
    this.actions,
  });

  final String title;
  final VoidCallback onClose;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
          ...?actions,
          IconButton(
            icon: const Icon(Icons.close),
            color:
                theme.extension<RuQiThemeExtension>()?.inkMuted ??
                theme.colorScheme.onSurfaceVariant,
            tooltip: '关闭',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
