import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/extension.dart';
import '../theme/tokens.dart';

/// 规范 §6.2 `FloatingPromo`：浮动优惠弹层。
///
/// 触发条件取先到者：页面停留 [autoShowDelay] 或滚动深度
/// [scrollThreshold]（`pixels >= maxScrollExtent * 0.8`）。
/// 桌面右下角 360px；移动端全宽底部弹层。
class FloatingPromo extends StatefulWidget {
  const FloatingPromo({
    super.key,
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.onCtaPressed,
    this.autoShowDelay = const Duration(seconds: 15),
    this.scrollThreshold = 0.8,
    this.scrollController,
    this.onDismissed,
  });

  final String headline;
  final String body;
  final String ctaLabel;
  final VoidCallback onCtaPressed;

  /// 页面停留时长。
  final Duration autoShowDelay;

  /// 滚动深度阈值。
  final double scrollThreshold;

  final ScrollController? scrollController;

  /// 永久关闭回调（调用方持久化偏好）。
  final VoidCallback? onDismissed;

  @override
  State<FloatingPromo> createState() => _FloatingPromoState();
}

class _FloatingPromoState extends State<FloatingPromo> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.autoShowDelay, _show);
    widget.scrollController?.addListener(_handleScroll);
    // `maxScrollExtent` 在首帧布局完成前不可用，延后到布局后检查。
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void didUpdateWidget(FloatingPromo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_handleScroll);
      widget.scrollController?.addListener(_handleScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.scrollController?.removeListener(_handleScroll);
    super.dispose();
  }

  void _show() {
    if (!mounted || _visible) return;
    setState(() => _visible = true);
  }

  void _handleScroll() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients || _visible) return;
    final max = controller.position.maxScrollExtent;
    if (max <= 0) return;
    if (controller.position.pixels >= max * widget.scrollThreshold) {
      _show();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 768;
        return Align(
          alignment: wide ? Alignment.bottomRight : Alignment.bottomCenter,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: RuQiMotion.resolve(context, RuQiMotion.normal),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.2),
              duration: RuQiMotion.resolve(context, RuQiMotion.normal),
              curve: RuQiMotion.resolveCurve(context, RuQiMotion.easeOut),
              child: Padding(
                padding: wide
                    ? const EdgeInsets.all(32)
                    : const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: wide ? 360 : constraints.maxWidth,
                  constraints: BoxConstraints(
                    maxWidth: wide ? 360 : constraints.maxWidth,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: wide
                        ? BorderRadius.circular(12)
                        : const BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border.all(color: ext.hairlineStrong, width: 1),
                    boxShadow: isDark ? null : RuQiElevation.shadowLg,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.headline,
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              IconButton(
                                onPressed: _dismiss,
                                tooltip: '关闭',
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: ext.inkMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: RuQiSpacing.xs),
                          Text(
                            widget.body,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: RuQiSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: widget.onCtaPressed,
                              child: Text(widget.ctaLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
