import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 元信息行：标签 + 值（创建 / 最后编辑等）。
class UserMetaRow extends StatelessWidget {
  const UserMetaRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// 可复制的值行。
class UserCopyRow extends StatelessWidget {
  const UserCopyRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.md,
        vertical: RuQiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: RuQiSpacing.md),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: RuQiTextStyles.mono.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label已复制'), duration: RuQiMotion.fast),
              );
            },
            style: RuQiButtonStyles.secondary(context),
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }
}
