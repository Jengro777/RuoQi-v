import 'package:flutter/widgets.dart';

/// 产品端类型。
///
/// 每个 App 在入口声明自己是 PC 端还是移动端，
/// 布局代码据此选择宽屏/窄屏的 UI 形态。
enum RuoQiPlatform {
  /// PC 端：宽屏布局（后台管理、数据表格、侧边导航）。
  pc,

  /// 移动端：窄屏布局（底部导航、卡片流、单列表单）。
  mobile,
}

/// 常用响应式断点（对齐 DESIGN-consensus.md §8）。
abstract final class RuoQiBreakpoints {
  /// 宽屏：内容最大宽 1440。
  static const double wide = 1440;

  /// 桌面：卡片 3 列、定价 3–4 列。
  static const double desktop = 1024;

  /// 平板：卡片 2 列、定价 2 列、导航收起。
  static const double tablet = 768;

  /// 手机：单列、display 字号下调。
  static const double mobile = 428;
}

/// 依据屏幕宽度推断端类型（未显式声明 Scope 时的兜底逻辑）。
RuoQiPlatform ruoQiPlatformFromSize(Size size) {
  return size.width >= RuoQiBreakpoints.desktop
      ? RuoQiPlatform.pc
      : RuoQiPlatform.mobile;
}

/// 在 App 入口声明当前应用的端类型。
///
/// ```dart
/// RuoQiPlatformScope(
///   platform: RuoQiPlatform.pc,
///   child: MaterialApp(...),
/// )
/// ```
class RuoQiPlatformScope extends InheritedWidget {
  const RuoQiPlatformScope({
    super.key,
    required this.platform,
    required super.child,
  });

  final RuoQiPlatform platform;

  /// 读取当前端类型；没有显式声明时按屏幕宽度推断。
  static RuoQiPlatform of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RuoQiPlatformScope>();
    return scope?.platform ?? ruoQiPlatformFromSize(MediaQuery.sizeOf(context));
  }

  @override
  bool updateShouldNotify(RuoQiPlatformScope oldWidget) =>
      platform != oldWidget.platform;
}
