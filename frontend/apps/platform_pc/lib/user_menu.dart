import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// 顶栏头像直径：与顶栏背景模式切换（三个 26px 选项）搭配，避免顶栏头重。
const double _avatarSize = 28;

/// 在线圆点直径（含 2px 顶栏底色描边）。
const double _onlineDotSize = 10;

/// 平台端顶栏账号菜单：头像按钮 + 下拉面板（个人信息 / 个人资料 / 退出）。
///
/// 面板贴头像右下方展开，顶部带指向头像的小尖角；点击面板外任意位置关闭。
/// 颜色一律取语义角色：面板 `surface` + `outlineVariant` 描边、悬停
/// `surfaceContainerHigh`、在线圆点 `success`；暗色模式不加阴影（§4.1）。
class UserMenuButton extends StatefulWidget {
  const UserMenuButton({
    super.key,
    required this.onProfile,
    required this.onExit,
    this.name = 'Jengro',
    this.email = 'avey777@outlook.com',
  });

  /// 原型占位身份；接入真实账号体系后由上层传入。
  final String name;
  final String email;

  /// 打开个人资料。
  final VoidCallback onProfile;

  /// 退出登录。
  final VoidCallback onExit;

  @override
  State<UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<UserMenuButton> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  void _toggle() {
    if (_controller.isShowing) {
      _controller.hide();
    } else {
      _controller.show();
    }
  }

  /// 菜单项统一「先收起面板再执行动作」，避免面板盖住动作弹层。
  void _select(VoidCallback action) {
    _controller.hide();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) => Stack(
        children: [
          // 面板外点击关闭：整屏透明遮罩，不改变其它弹层的命中行为。
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _controller.hide,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, _UserMenuPanel.notchSize / 2),
            child: _UserMenuPanel(
              name: widget.name,
              email: widget.email,
              onProfile: () => _select(widget.onProfile),
              onExit: () => _select(widget.onExit),
            ),
          ),
        ],
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: Semantics(
          button: true,
          label: '账号菜单',
          child: Tooltip(
            message: '账号菜单',
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _toggle,
                customBorder: const StadiumBorder(),
                child: _Avatar(name: widget.name),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 头像：`brandDark` 圆形 + 首字母，右上角 `success` 在线圆点。
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SizedBox(
      width: _avatarSize,
      height: _avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ext?.brandDark ?? theme.colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ext?.onDark ?? theme.colorScheme.surface,
                    fontWeight: FontWeight.w700,
                    fontSize: _avatarSize * 0.46,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: _onlineDotSize,
              height: _onlineDotSize,
              decoration: BoxDecoration(
                color: ext?.success ?? theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 下拉面板：姓名 / 邮箱 + 分隔线 + 菜单项（图标 + 文案 + 快捷键角标）。
class _UserMenuPanel extends StatelessWidget {
  const _UserMenuPanel({
    required this.name,
    required this.email,
    required this.onProfile,
    required this.onExit,
  });

  final String name;
  final String email;
  final VoidCallback onProfile;
  final VoidCallback onExit;

  /// 面板宽度：够放「姓名 / 邮箱 + 菜单项 + 快捷键角标」。
  static const double width = 236;

  /// 指向头像的尖角尺寸与右侧偏移（尖角中心对准头像圆心）。
  static const double notchSize = 12;
  static const double _notchRight = _avatarSize / 2 - notchSize / 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<RuQiThemeExtension>();
    final menuColor = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final radius = BorderRadius.circular(RuQiSpacing.sm);

    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            // 顶部让出尖角高度，面板正文正好贴在顶栏下沿。
            padding: const EdgeInsets.only(top: notchSize / 2),
            child: Container(
              decoration: BoxDecoration(
                color: menuColor,
                borderRadius: radius,
                border: Border.all(color: borderColor),
                // 暗色模式不用阴影，靠描边分层（§4.1）。
                boxShadow: RuQiElevation.shadowsFor(theme.brightness, 2),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        RuQiSpacing.md,
                        RuQiSpacing.md,
                        RuQiSpacing.md,
                        RuQiSpacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  ext?.inkMuted ??
                                  colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UserMenuItem(
                            icon: Icons.person_outline,
                            label: '个人资料',
                            shortcut: 'P',
                            onTap: onProfile,
                          ),
                          _UserMenuItem(
                            icon: Icons.logout,
                            label: '退出',
                            shortcut: 'L',
                            onTap: onExit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: _notchRight,
            top: 0,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: notchSize,
                height: notchSize,
                decoration: BoxDecoration(
                  color: menuColor,
                  border: Border(
                    top: BorderSide(color: borderColor),
                    left: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 菜单项：左图标 + 文案 + 右侧快捷键角标。
class _UserMenuItem extends StatelessWidget {
  const _UserMenuItem({
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String shortcut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<RuQiThemeExtension>();
    return InkWell(
      onTap: onTap,
      hoverColor: colorScheme.surfaceContainerLow,
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: RuQiSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: ext?.hairlineStrong ?? colorScheme.outline,
                  ),
                ),
                child: Text(
                  shortcut,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ext?.inkTertiary ?? colorScheme.onSurfaceVariant,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
