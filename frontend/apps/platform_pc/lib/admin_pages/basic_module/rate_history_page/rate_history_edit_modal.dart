import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'rate_history_models.dart';

/// 打开汇率新增 / 编辑面板。
Future<void> showRateHistoryEditPanel(
  BuildContext context, {
  RateHistory? rate,
}) {
  return showSystemSettingsPanel(
    context,
    title: rate == null ? '添加汇率' : '编辑汇率',
    child: RateHistoryEditForm(rate: rate),
  );
}

/// 汇率新增 / 编辑表单。
class RateHistoryEditForm extends StatefulWidget {
  const RateHistoryEditForm({super.key, this.rate});

  final RateHistory? rate;

  @override
  State<RateHistoryEditForm> createState() => _RateHistoryEditFormState();
}

class _RateHistoryEditFormState extends State<RateHistoryEditForm> {
  late final TextEditingController _from;
  late final TextEditingController _to;
  late final TextEditingController _originalRate;
  late final TextEditingController _rateFloat;
  late final TextEditingController _effectiveAt;
  late final TextEditingController _expireAt;
  late String _type;

  static const _types = ['固定汇率', '实时汇率(Xe)'];
  static const _currencies = ['USD', 'CNY', 'GHS', 'VND', 'ETB'];

  @override
  void initState() {
    super.initState();
    final rate = widget.rate;
    _type = rate?.type ?? '固定汇率';
    _from = TextEditingController(text: rate?.from ?? 'USD');
    _to = TextEditingController(text: rate?.to ?? '');
    _originalRate = TextEditingController(text: rate?.originalRate ?? '');
    _rateFloat = TextEditingController(text: rate?.rateFloat ?? '');
    _effectiveAt = TextEditingController(text: rate?.effectiveAt ?? '');
    _expireAt = TextEditingController(text: rate?.expireAt == '--' ? '' : (rate?.expireAt ?? ''));
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _originalRate.dispose();
    _rateFloat.dispose();
    _effectiveAt.dispose();
    _expireAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: '汇率类型'),
                  items: [
                    for (final type in _types)
                      DropdownMenuItem(value: type, child: Text(type)),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _from.text,
                        decoration: const InputDecoration(labelText: '原货币'),
                        items: [
                          for (final code in _currencies)
                            DropdownMenuItem(value: code, child: Text(code)),
                        ],
                        onChanged: (v) =>
                            setState(() => _from.text = v ?? _from.text),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _to.text.isEmpty ? null : _to.text,
                        decoration: const InputDecoration(labelText: '目标货币'),
                        items: [
                          for (final code in _currencies)
                            DropdownMenuItem(value: code, child: Text(code)),
                        ],
                        onChanged: (v) =>
                            setState(() => _to.text = v ?? _to.text),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _originalRate,
                        decoration: const InputDecoration(labelText: '原汇率'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _rateFloat,
                        decoration: const InputDecoration(labelText: '汇率浮动'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _effectiveAt,
                        decoration: const InputDecoration(
                          labelText: '生效时间',
                          hintText: '如 2022/02/02 02:02:03',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _expireAt,
                        decoration: const InputDecoration(
                          labelText: '结束时间',
                          hintText: '留空表示不结束',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.rate == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
