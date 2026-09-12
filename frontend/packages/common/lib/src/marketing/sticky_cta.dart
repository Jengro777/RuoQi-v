import 'package:flutter/material.dart';

import '../adaptive/platform.dart';
import '../theme/buttons.dart';
import '../theme/extension.dart';
import '../theme/tokens.dart';

/// 规范 §6.2 `StickyCta`：吸附底部 CTA。
///
/// 滚动超过首屏 70% 自动滑入；宽屏两列（价格 + 按钮），
/// <768px 纵向堆叠且按钮全宽；始终提供关闭按钮。
class StickyCta extends StatefulWidget {
  const StickyCta({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    this.price,
    this.originalPrice,
    this.controller,
    this.visible = false,
    this.onDismissed,
  });

  final String buttonLabel;
  final VoidCallback onPressed;

  /// 现价：`headlineMedium` + 700 + `accentEnergy`。
  final String? price;

  /// 划线原价：`inkTertiary`。
  final String? originalPrice;

  /// 滚动控制器；越过首屏 70% 自动滑入。
  final ScrollController? controller;

  /// 手动显隐（不传 [controller] 时）。
  final bool visible;

  /// 关闭时回调（调用方持久化本次会话偏好）。
  final VoidCallback? onDismissed;

  @override
  State<StickyCta> createState() => _StickyCtaState();
}

class _StickyCtaState extends State<StickyCta> {
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = widget.visible;
    widget.controller?.addListener(_handleScroll);
    if (widget.controller != null) {
      _handleScroll();
    }
  }

  @override
  void didUpdateWidget(StickyCta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleScroll);
      widget.controller?.addListener(_handleScroll);
      _handleScroll();
    }
    if (oldWidget.visible != widget.visible && widget.controller == null) {
      _visible = widget.visible;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    final controller = widget.controller;
    if (controller == null || !controller.hasClients) return;
    final passed =
        controller.position.pixels >=
        controller.position.viewportDimension * 0.7;
    if (passed != _visible) {
      setState(() => _visible = passed);
    }
  }

  void _dismiss() {
    setState(() => _visible = false);
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 1),
      duration: RuQiMotion.resolve(context, RuQiMotion.normal),
      curve: RuQiMotion.resolveCurve(context, RuQiMotion.easeOut),
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: RuQiMotion.resolve(context, RuQiMotion.fast),
        curve: Curves.easeOut,
        child: Material(
          color: theme.colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              boxShadow: isDark ? null : RuQiElevation.shadowLg,
            ),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow =
                          constraints.maxWidth < RuoQiBreakpoints.tablet;
                      final priceBlock = _PriceBlock(
                        price: widget.price,
                        originalPrice: widget.originalPrice,
                      );
                      final button = FilledButton(
                        onPressed: widget.onPressed,
                        style: RuQiButtonStyles.primary(context),
                        child: Text(widget.buttonLabel),
                      );
                      final close = IconButton(
                        onPressed: _dismiss,
                        tooltip: '关闭',
                        icon: Icon(Icons.close, color: ext.inkMuted),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RuQiSpacing.lg,
                          vertical: RuQiSpacing.md,
                        ),
                        child: narrow
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: priceBlock),
                                      close,
                                    ],
                                  ),
                                  const SizedBox(height: RuQiSpacing.sm),
                                  SizedBox(
                                    width: double.infinity,
                                    child: button,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: priceBlock),
                                  const SizedBox(width: RuQiSpacing.md),
                                  button,
                                  const SizedBox(width: RuQiSpacing.xs),
                                  close,
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({this.price, this.originalPrice});

  final String? price;
  final String? originalPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    if (price == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          price!,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: ext.accentEnergy,
          ),
        ),
        if (originalPrice != null) ...[
          const SizedBox(width: RuQiSpacing.xs),
          Text(
            originalPrice!,
            style: theme.textTheme.titleSmall?.copyWith(
              color: ext.inkTertiary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}
