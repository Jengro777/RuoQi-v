import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';

/// 打开阿里云短信配置面板。
Future<void> showAliyunSmsSettingsDialog(BuildContext context) {
  return showSystemSettingsPanel(
    context,
    title: '阿里云短信 设置',
    child: const AliyunSmsSettingsForm(),
  );
}

/// 阿里云短信配置表单（参照 设置/短信/阿里云短信 原型）。
class AliyunSmsSettingsForm extends StatefulWidget {
  const AliyunSmsSettingsForm({super.key});

  @override
  State<AliyunSmsSettingsForm> createState() => _AliyunSmsSettingsFormState();
}

class _AliyunSmsSettingsFormState extends State<AliyunSmsSettingsForm> {
  int _areaCodeMode = 0; // 0 跟随运营商 / 1 指定区号
  late final TextEditingController _accessKeyId;
  late final TextEditingController _accessKeySecret;
  late final TextEditingController _signature;
  late final TextEditingController _bindingCode;
  late final TextEditingController _areaCodes;

  static const _setupSteps = [
    '第一步：注册开通阿里云账号，进行实名认证；',
    '第二步：绑定企业支付宝；',
    '第三步：开通短信服务，进入控制台创建 AccessKey，'
        '获取 AccessKey ID 和 AccessKey Secret；',
    '第四步：输入 AppKey、AccessKeyId 和 AccessKeySecret 进行绑定；',
  ];

  @override
  void initState() {
    super.initState();
    _accessKeyId = TextEditingController(text: '54678676');
    _accessKeySecret = TextEditingController(text: '456786786');
    _signature = TextEditingController();
    _bindingCode = TextEditingController(text: '2224545');
    _areaCodes = TextEditingController(
      text: '8lw-ld0xpvae-2d7,8lw-ld0xpvae-2df',
    );
  }

  @override
  void dispose() {
    _accessKeyId.dispose();
    _accessKeySecret.dispose();
    _signature.dispose();
    _bindingCode.dispose();
    _areaCodes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _accessKeyId,
            decoration: const InputDecoration(labelText: 'AccessKeyID*'),
          ),
          const SizedBox(height: RuQiSpacing.md),
          TextField(
            controller: _accessKeySecret,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'AccessKeySecret*'),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Container(
            padding: const EdgeInsets.all(RuQiSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '配置说明：',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.xs),
                for (final step in _setupSteps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      step,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          TextField(
            controller: _signature,
            decoration: const InputDecoration(labelText: '短信签名'),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bindingCode,
                  decoration: const InputDecoration(labelText: '绑定验证'),
                ),
              ),
              const SizedBox(width: RuQiSpacing.sm),
              OutlinedButton(
                onPressed: () {},
                style: RuQiButtonStyles.secondary(context),
                child: const Text('修改'),
              ),
            ],
          ),
          const SizedBox(height: RuQiSpacing.md),
          Text(
            '关联国际电话区号',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          RadioGroup<int>(
            groupValue: _areaCodeMode,
            onChanged: (value) {
              if (value != null) {
                setState(() => _areaCodeMode = value);
              }
            },
            child: Column(
              children: [
                RadioListTile<int>(
                  value: 0,
                  title: const Text('跟随运营商'),
                  subtitle: Text(
                    '使用运营商默认支持的国际电话区号。'
                    '若有其它短信服务配置指定国际电话区号时，'
                    '则该区号段的短信服务使用指定的短信服务商。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                RadioListTile<int>(
                  value: 1,
                  title: const Text('指定区号'),
                  subtitle: Text(
                    '使用运营商指定国际电话区号，则该区号段的'
                    '短信服务使用指定的短信服务商，'
                    '同一个区号只能绑定一个服务商。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_areaCodeMode == 1) ...[
            TextField(
              controller: _areaCodes,
              decoration: const InputDecoration(
                labelText: '国际电话区号',
                helperText: '多个区号用英文逗号分隔，如 +86,+852。',
              ),
            ),
          ],
          const SizedBox(height: RuQiSpacing.lg),
          Row(
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
                child: const Text('保存并启用'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
