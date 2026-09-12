import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// 规范 §6.2 `SocialProofBar`：社交证明条。
///
/// 胶囊容器 + 28px 头像栈 + 消息文本；动作文字主色加粗。
/// [inline] 为内联变体：无背景，嵌入 Hero。
class SocialProofBar extends StatelessWidget {
  const SocialProofBar({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.avatars = const [],
    this.inline = false,
  });

  /// 消息文本，如「200+ 人今天加入」。
  final String message;

  /// 动作文字，如「立即加入」。
  final String? actionLabel;

  final VoidCallback? onAction;

  /// 调用方传入的 28px 头像。
  final List<Widget> avatars;

  /// 内联变体：无背景、无描边，嵌入 Hero 场景。
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (avatars.isNotEmpty) ...[
          _AvatarStack(avatars: avatars),
          const SizedBox(width: RuQiSpacing.sm),
        ],
        Flexible(
          child: Text(
            message,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: RuQiSpacing.xs),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    if (inline) return content;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.md,
        vertical: RuQiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: content,
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});

  final List<Widget> avatars;

  @override
  Widget build(BuildContext context) {
    const size = 28.0;
    const overlap = 8.0;
    final width = avatars.length * size - (avatars.length - 1) * overlap;
    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(
              left: i * (size - overlap),
              top: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipOval(child: avatars[i]),
              ),
            ),
        ],
      ),
    );
  }
}

/// 规范 §6.2 `SocialProofTicker`：无缝横向滚动社交证明。
///
/// 内容复制一份做无缝滚动；系统减少动态时退化为静态列表。
class SocialProofTicker extends StatefulWidget {
  const SocialProofTicker({
    super.key,
    required this.messages,
    this.duration = const Duration(seconds: 30),
    this.itemSpacing = 32,
  });

  final List<String> messages;

  /// 一轮完整滚动时长。
  final Duration duration;

  /// 消息之间间距。
  final double itemSpacing;

  @override
  State<SocialProofTicker> createState() => _SocialProofTickerState();
}

class _SocialProofTickerState extends State<SocialProofTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final textDirection = Directionality.of(context);

    Widget item(String message) {
      return Padding(
        padding: EdgeInsets.only(right: widget.itemSpacing),
        child: Text(message, style: style),
      );
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      return Wrap(
        spacing: widget.itemSpacing,
        runSpacing: RuQiSpacing.xs,
        children: [for (final m in widget.messages) item(m)],
      );
    }

    final widths = <double>[];
    for (final m in widget.messages) {
      final painter = TextPainter(
        text: TextSpan(text: m, style: style),
        textDirection: textDirection,
      )..layout();
      widths.add(painter.width + widget.itemSpacing);
    }
    final setWidth = widths.fold<double>(0, (a, b) => a + b);
    final duplicated = [...widget.messages, ...widget.messages];

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final dx = -_controller.value * setWidth;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: SizedBox(
              width: setWidth * 2,
              height: 28,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (final m in duplicated) item(m)],
              ),
            ),
          );
        },
      ),
    );
  }
}
