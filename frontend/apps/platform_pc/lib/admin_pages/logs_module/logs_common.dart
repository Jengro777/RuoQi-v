import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// 日志板块共用部件：筛选条。

/// 日志筛选条：关键字 + 时间范围 + 筛选 / 重置（规范 §6.5 输入与表单）。
///
/// 搜索框与时间范围按钮严格等高（[RuQiSearchField.height]）；筛选为主操作、
/// 重置为行内文字动作。
class LogFilterBar extends StatefulWidget {
  const LogFilterBar({
    super.key,
    required this.onQueryChanged,
    this.onFilter,
  });

  final ValueChanged<String> onQueryChanged;

  /// 点击「筛选」；为空时给出演示提示。
  final VoidCallback? onFilter;

  @override
  State<LogFilterBar> createState() => _LogFilterBarState();
}

class _LogFilterBarState extends State<LogFilterBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickRange(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('时间范围筛选（演示）'),
        duration: RuQiMotion.normal,
      ),
    );
  }

  void _reset() {
    _controller.clear();
    widget.onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: RuQiSearchField(
            hintText: '搜索',
            controller: _controller,
            onChanged: widget.onQueryChanged,
          ),
        ),
        const SizedBox(width: RuQiSpacing.md),
        Expanded(
          flex: 2,
          child: SizedBox(
            // 与搜索框严格等高（§6.5）。
            height: RuQiSearchField.height,
            child: OutlinedButton.icon(
              style: RuQiButtonStyles.secondary(context),
              onPressed: () => _pickRange(context),
              icon: const Icon(Icons.event_outlined, size: 16),
              label: const Text(
                '00/00 0000 00:00:00 ～ 00/00 0000 00:00:00',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: RuQiSpacing.sm),
        FilledButton(
          style: RuQiButtonStyles.primary(context),
          onPressed: widget.onFilter ?? () => _pickRange(context),
          child: const Text('筛选'),
        ),
        const SizedBox(width: RuQiSpacing.xxs),
        TextButton(
          style: RuQiButtonStyles.link(context),
          onPressed: _reset,
          child: const Text('重置'),
        ),
      ],
    );
  }
}
