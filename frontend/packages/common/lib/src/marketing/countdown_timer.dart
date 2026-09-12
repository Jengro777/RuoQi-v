import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/extension.dart';
import '../theme/tokens.dart';

/// 规范 §6.2 `CountdownTimer`：倒计时组件。
///
/// 每秒刷新时 / 分 / 秒，数字变化时做一次轻微脉冲；
/// 系统减少动态时脉冲减弱（仅数字变化）。到期仅回调一次
/// [onExpired]，且不自动播放声音。
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.endTime,
    this.compact = false,
    this.labels = const ['时', '分', '秒'],
    this.separator = ':',
    this.stacked = false,
    this.onExpired,
  });

  /// 倒计时截止时间。
  final DateTime endTime;

  /// 紧凑变体：数字 24、块内边距 2/4、最小宽 36。
  final bool compact;

  /// 单位标签。
  final List<String> labels;

  /// 单位之间的分隔符。
  final String separator;

  /// 移动端纵向堆叠、居中（规范 §8 组件响应式行为）。
  final bool stacked;

  /// 到期触发一次；调用方据此禁用周边 CTA。
  final VoidCallback? onExpired;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late Duration _remaining;
  bool _expiredNotified = false;
  late final AnimationController _pulseController;
  late final Animation<double> _scale;
  int _lastDigitSum = -1;

  @override
  void initState() {
    super.initState();
    _remaining = _clip(widget.endTime.difference(DateTime.now()));
    _pulseController = AnimationController(
      vsync: this,
      duration: RuQiMotion.fast,
    );
    _scale = Tween<double>(begin: 1.05, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: RuQiMotion.easePulse),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Duration _clip(Duration value) => value.isNegative ? Duration.zero : value;

  List<int> _digits() {
    final totalSeconds = _remaining.inSeconds;
    return [
      totalSeconds ~/ 3600,
      (totalSeconds % 3600) ~/ 60,
      totalSeconds % 60,
    ];
  }

  void _tick() {
    setState(() {
      _remaining = _clip(widget.endTime.difference(DateTime.now()));
      if (_remaining == Duration.zero && !_expiredNotified) {
        _expiredNotified = true;
        widget.onExpired?.call();
      }
    });
    _pulseIfChanged();
  }

  void _pulseIfChanged() {
    final sum = _digits().fold<int>(0, (a, b) => a + b);
    if (sum != _lastDigitSum) {
      _lastDigitSum = sum;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _pulseController.forward(from: 0);
      }
    }
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      setState(() {
        _remaining = _clip(widget.endTime.difference(DateTime.now()));
      });
      _pulseIfChanged();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = ruoQiThemeExt(context);
    final digits = _digits();
    final labels = widget.labels;
    final unitCount = digits.length;
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: ext.inkMuted);

    final blocks = <Widget>[];
    for (var i = 0; i < unitCount; i++) {
      if (i > 0 && !widget.stacked) {
        blocks.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 4 : 8),
            child: Text(
              widget.separator,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: ext.inkTertiary),
            ),
          ),
        );
      }
      final digit = digits[i].toString().padLeft(2, '0');
      blocks.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                constraints: BoxConstraints(minWidth: widget.compact ? 36 : 48),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 4 : 8,
                  vertical: widget.compact ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  digit,
                  style: RuQiTextStyles.countdownDigit.copyWith(
                    fontSize: widget.compact ? 24 : 36,
                    color: ext.accentEnergy,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.compact ? 2 : 4),
            Text(i < labels.length ? labels[i] : '', style: labelStyle),
          ],
        ),
      );
    }

    final hours = digits[0].toString().padLeft(2, '0');
    final minutes = digits[1].toString().padLeft(2, '0');
    final seconds = digits[2].toString().padLeft(2, '0');

    return Semantics(
      liveRegion: true,
      label: '剩余时间 $hours:$minutes:$seconds',
      child: widget.stacked
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final block in blocks) ...[
                  if (block != blocks.first) const SizedBox(height: 12),
                  block,
                ],
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: blocks,
            ),
    );
  }
}
