import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'currency_models.dart';

/// 打开货币新增 / 编辑面板。
Future<void> showCurrencyEditPanel(
  BuildContext context, {
  Currency? currency,
}) {
  return showSystemSettingsPanel(
    context,
    title: currency == null ? '添加货币' : '编辑货币',
    child: CurrencyEditForm(currency: currency),
  );
}

/// 货币新增 / 编辑表单。
class CurrencyEditForm extends StatefulWidget {
  const CurrencyEditForm({super.key, this.currency});

  final Currency? currency;

  @override
  State<CurrencyEditForm> createState() => _CurrencyEditFormState();
}

class _CurrencyEditFormState extends State<CurrencyEditForm> {
  late final TextEditingController _code;
  late final TextEditingController _symbol;
  late final TextEditingController _zhName;
  late final TextEditingController _enName;
  late final TextEditingController _decimals;
  late final TextEditingController _rateFloat;
  bool _isBase = false;

  @override
  void initState() {
    super.initState();
    final currency = widget.currency;
    _code = TextEditingController(text: currency?.code ?? '');
    _symbol = TextEditingController(text: currency?.symbol ?? '');
    _zhName = TextEditingController(text: currency?.zhName ?? '');
    _enName = TextEditingController(text: currency?.enName ?? '');
    _decimals = TextEditingController(text: '${currency?.decimals ?? 2}');
    _rateFloat = TextEditingController(text: currency?.rateFloat ?? '');
    _isBase = currency?.isBase ?? false;
  }

  @override
  void dispose() {
    _code.dispose();
    _symbol.dispose();
    _zhName.dispose();
    _enName.dispose();
    _decimals.dispose();
    _rateFloat.dispose();
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code,
                        decoration: const InputDecoration(
                          labelText: '*货币代码',
                          hintText: '如 USD',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _symbol,
                        decoration: const InputDecoration(
                          labelText: '*符号',
                          hintText: '如 \$',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _zhName,
                  decoration: const InputDecoration(
                    labelText: '货币名称：简体中文',
                    hintText: '如 美元',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _enName,
                  decoration: const InputDecoration(
                    labelText: '英文',
                    hintText: '如 dollar',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _decimals,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '小数位'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _rateFloat,
                        decoration: const InputDecoration(
                          labelText: '汇率浮动',
                          hintText: '如 +0.00020',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                SwitchListTile(
                  value: _isBase,
                  onChanged: (v) => setState(() => _isBase = v),
                  title: const Text('设为基础货币'),
                  subtitle: const Text('基础货币作为全站汇率的换算锚点。'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.currency == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
