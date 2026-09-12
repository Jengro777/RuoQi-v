import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 日志板块共用部件：筛选条。

/// 日志筛选条：关键字 + 时间范围（规范 §6.5 输入与表单）。
class LogFilterBar extends StatelessWidget {
  const LogFilterBar({
    super.key,
    required this.onQueryChanged,
  });

  final ValueChanged<String> onQueryChanged;

  void _pickRange(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('时间范围筛选（演示）'),
        duration: RuQiMotion.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              hintText: '搜索',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: RuQiSpacing.md),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            style: RuQiButtonStyles.secondary(context),
            onPressed: () => _pickRange(context),
            icon: const Icon(Icons.event_outlined, size: 16),
            label: Text(
              '00/00 0000 00:00:00 ～ 00/00 0000 00:00:00',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: RuQiSpacing.sm),
        TextButton(
          style: RuQiButtonStyles.tertiary(context),
          onPressed: () {},
          child: const Text('清空'),
        ),
        const SizedBox(width: RuQiSpacing.xs),
        FilledButton(
          style: RuQiButtonStyles.primary(context),
          onPressed: () => _pickRange(context),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
