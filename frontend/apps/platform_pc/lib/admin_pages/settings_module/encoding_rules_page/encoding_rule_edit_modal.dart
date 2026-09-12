import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';

import 'encoding_rule_models.dart';

/// 打开单号规则编辑面板（与内容区同尺寸，无阴影遮罩、右侧滑入）。
Future<void> showEncodingRuleEditDialog(
  BuildContext context,
  EncodingRule rule,
) {
  return showSystemSettingsPanel(
    context,
    title: '${rule.name.replaceAll('\n', ' ')} 编辑',
    child: EncodingRuleEditForm(rule: rule),
  );
}

/// 单号规则编辑表单（标题条与关闭按钮由设置面板提供）。
class EncodingRuleEditForm extends StatefulWidget {
  const EncodingRuleEditForm({super.key, required this.rule});

  final EncodingRule rule;

  @override
  State<EncodingRuleEditForm> createState() => _EncodingRuleEditFormState();
}

class _EncodingRuleEditFormState extends State<EncodingRuleEditForm> {
  late final TextEditingController _name;
  late final TextEditingController _prefix;
  late final TextEditingController _rule;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.rule.name.replaceAll('\n', ' '));
    _prefix = TextEditingController(text: widget.rule.prefix);
    _rule = TextEditingController(text: widget.rule.rule);
    _note = TextEditingController(text: widget.rule.note);
  }

  @override
  void dispose() {
    _name.dispose();
    _prefix.dispose();
    _rule.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    helperText: '规则名称，如 销售单号、批次号。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _prefix,
                  decoration: InputDecoration(
                    labelText: '单号前缀',
                    helperText: '用于单号开头的大写字母 / 数字前缀。',
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _prefix,
                      builder: (context, value, _) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RuQiSpacing.sm,
                        ),
                        child: Center(
                          child: Text(
                            value.text.isEmpty ? '--' : value.text,
                            style: RuQiTextStyles.mono.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _rule,
                  maxLines: 7,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  decoration: const InputDecoration(
                    labelText: '生成单号规则',
                    alignLabelWithHint: true,
                    helperText: '逐条列出生成约束，每行一条。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '说明',
                    alignLabelWithHint: true,
                    helperText: '补充说明或示例，如 eg：BN20220202010305。',
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RuQiSpacing.lg,
            RuQiSpacing.sm,
            RuQiSpacing.lg,
            RuQiSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.tertiary(context),
                child: const Text('取消'),
              ),
              const SizedBox(width: RuQiSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.primary(context),
                child: const Text('保存生效'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
