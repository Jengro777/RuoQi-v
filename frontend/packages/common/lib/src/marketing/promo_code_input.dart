import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/buttons.dart';
import '../theme/extension.dart';
import '../theme/tokens.dart';

/// 优惠码应用结果。
sealed class PromoCodeResult {
  const PromoCodeResult();
}

/// 优惠码有效。
class PromoCodeValid extends PromoCodeResult {
  const PromoCodeValid(this.discount);

  /// 优惠金额（非负）。
  final double discount;
}

/// 优惠码无效。
class PromoCodeInvalid extends PromoCodeResult {
  const PromoCodeInvalid(this.message);

  final String message;
}

/// 规范 §6.2 `PromoCodeInput`：优惠码输入。
///
/// 状态机：`idle` → `applying` → `invalid` / `valid`；
/// 应用后展示优惠行（原价划线、优惠额、最终价）。
class PromoCodeInput extends StatefulWidget {
  const PromoCodeInput({
    super.key,
    required this.price,
    required this.onApply,
    this.onRemove,
  });

  /// 当前价格（用于计算最终价）。
  final double price;

  /// 校验优惠码；可同步或异步返回。
  final FutureOr<PromoCodeResult> Function(String code) onApply;

  /// 移除优惠码时回调。
  final VoidCallback? onRemove;

  @override
  State<PromoCodeInput> createState() => _PromoCodeInputState();
}

enum _PromoStatus { idle, applying, invalid, valid }

class _PromoCodeInputState extends State<PromoCodeInput> {
  final _controller = TextEditingController();
  _PromoStatus _status = _PromoStatus.idle;
  String? _message;
  double _discount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _status = _PromoStatus.applying;
      _message = null;
    });
    final result = await widget.onApply(code);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case PromoCodeValid(:final discount):
          _status = _PromoStatus.valid;
          _discount = discount.clamp(0, widget.price);
          _message = '优惠码已应用';
        case PromoCodeInvalid(:final message):
          _status = _PromoStatus.invalid;
          _message = message;
      }
    });
  }

  void _remove() {
    setState(() {
      _status = _PromoStatus.idle;
      _message = null;
      _discount = 0;
    });
    _controller.clear();
    widget.onRemove?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final isError = _status == _PromoStatus.invalid;
    final isSuccess = _status == _PromoStatus.valid;
    final borderColor = isError
        ? theme.colorScheme.error
        : isSuccess
        ? ext.success
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: _status != _PromoStatus.applying,
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  enabledBorder: borderColor == null
                      ? null
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                ),
                onSubmitted: (_) => _apply(),
              ),
            ),
            const SizedBox(width: RuQiSpacing.xs),
            if (_status == _PromoStatus.valid)
              OutlinedButton(
                onPressed: _remove,
                style: RuQiButtonStyles.secondary(context),
                child: const Text('Remove'),
              )
            else
              SizedBox(
                width: 96,
                child: _status == _PromoStatus.applying
                    ? OutlinedButton(
                        onPressed: null,
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: _apply,
                        style: RuQiButtonStyles.secondary(context),
                        child: const Text('Apply'),
                      ),
              ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: RuQiSpacing.xs),
            child: Text(
              _message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isError
                    ? theme.colorScheme.error
                    : isSuccess
                    ? ext.success
                    : ext.inkMuted,
              ),
            ),
          ),
        if (isSuccess) ...[
          const SizedBox(height: RuQiSpacing.md),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.only(top: RuQiSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¥${widget.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: ext.inkTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '优惠 -¥${_discount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ext.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥${(widget.price - _discount).toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ext.accentEnergy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
