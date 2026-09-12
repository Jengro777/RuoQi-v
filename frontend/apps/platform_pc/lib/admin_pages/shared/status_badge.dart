import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 状态徽章语义色调。
enum StatusTone { neutral, success, warning, error, info }

/// 规范 §6.6 状态徽章：语义色 @ 12% 背景 + 语义色文本，`StadiumBorder()`。
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    final Color color = switch (tone) {
      StatusTone.success => ext?.success ?? theme.colorScheme.onSurfaceVariant,
      StatusTone.warning => ext?.warning ?? theme.colorScheme.onSurfaceVariant,
      StatusTone.error => theme.colorScheme.error,
      StatusTone.info => ext?.info ?? theme.colorScheme.onSurfaceVariant,
      StatusTone.neutral =>
        ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
