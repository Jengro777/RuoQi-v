import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 设置-本地化 业务正文（替换静态原型复刻页）。
class LocalizationBody extends StatefulWidget {
  const LocalizationBody({super.key});

  @override
  State<LocalizationBody> createState() => _LocalizationBodyState();
}

class _LocalizationBodyState extends State<LocalizationBody> {
  int _currencyLabel = 0; // 0 符号 / 1 代码 / 2 命名
  int _currencyPosition = 0; // 0 列标题 / 1 表格单元
  int _separator = 2; // 100,000.00
  int _dateStyle = 2; // YYYY-MM-DD
  int _timeFormat = 1; // HH:mm:ss
  int _dayTime = 0; // 24 小时制

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        _Header(title: '本地化', description: '默认语言、时区、货币与日期时间的展示规则。'),
        const SizedBox(height: RuQiSpacing.lg),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CardTitle('语言与地区'),
                const SizedBox(height: RuQiSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: '简体中文',
                  decoration: const InputDecoration(labelText: '默认语言'),
                  items: const [
                    DropdownMenuItem(value: '简体中文', child: Text('简体中文')),
                    DropdownMenuItem(value: 'English', child: Text('English')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: RuQiSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: '中国',
                  decoration: const InputDecoration(
                    labelText: '国家/地区',
                    helperText: '系统默认的国家/地区，一般在用户 IP 识别失败时使用。',
                  ),
                  items: const [
                    DropdownMenuItem(value: '中国', child: Text('中国')),
                    DropdownMenuItem(value: '美国', child: Text('美国')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: RuQiSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: 'UTC +00:00',
                  decoration: const InputDecoration(labelText: '时区'),
                  items: const [
                    DropdownMenuItem(
                      value: 'UTC +00:00',
                      child: Text('UTC +00:00'),
                    ),
                    DropdownMenuItem(
                      value: 'UTC +08:00',
                      child: Text('UTC +08:00'),
                    ),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: RuQiSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: '星期日',
                  decoration: const InputDecoration(
                    labelText: '一周的第一天',
                    helperText: '这将影响数据的展示。',
                  ),
                  items: const [
                    DropdownMenuItem(value: '星期日', child: Text('星期日')),
                    DropdownMenuItem(value: '星期一', child: Text('星期一')),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.md),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CardTitle('货币'),
                const SizedBox(height: RuQiSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: 'Chinese Yuan',
                  decoration: const InputDecoration(labelText: '货币单位'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Chinese Yuan',
                      child: Text('Chinese Yuan'),
                    ),
                    DropdownMenuItem(
                      value: 'US Dollar',
                      child: Text('US Dollar'),
                    ),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: RuQiSpacing.xs),
                Text(
                  '货币初始化后，货币单位和小数位数不再被允许修改。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: '2',
                  decoration: const InputDecoration(labelText: '货币小数位'),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('0')),
                    DropdownMenuItem(value: '2', child: Text('2')),
                    DropdownMenuItem(value: '4', child: Text('4')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: RuQiSpacing.md),
                _RadioLabel('货币标签样式'),
                _RadioGroup<int>(
                  value: _currencyLabel,
                  onChanged: (v) => setState(() => _currencyLabel = v),
                  options: const [
                    (0, '符号 (CN¥)'),
                    (1, '代码 (CNY)'),
                    (2, '命名 (Chinese yuan)'),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                _RadioLabel('在哪里显示货币单位'),
                _RadioGroup<int>(
                  value: _currencyPosition,
                  onChanged: (v) => setState(() => _currencyPosition = v),
                  options: const [(0, '在列标题中'), (1, '在每个表格单元中')],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                _RadioLabel('数字分离器'),
                _RadioGroup<int>(
                  value: _separator,
                  onChanged: (v) => setState(() => _separator = v),
                  options: const [
                    (0, '100000.00'),
                    (1, '100 000,00'),
                    (2, '100,000.00'),
                    (3, "100'000.00"),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.md),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CardTitle('日期和时间'),
                const SizedBox(height: RuQiSpacing.sm),
                _RadioLabel('日期样式'),
                _RadioGroup<int>(
                  value: _dateStyle,
                  onChanged: (v) => setState(() => _dateStyle = v),
                  options: const [
                    (0, 'MM-DD-YYYY　　01-07-2018'),
                    (1, 'DD-MM-YYYY　　07-01-2018'),
                    (2, 'YYYY-MM-DD　　2018-01-07'),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                _RadioLabel('时间格式'),
                _RadioGroup<int>(
                  value: _timeFormat,
                  onChanged: (v) => setState(() => _timeFormat = v),
                  options: const [
                    (0, 'HH:mm'),
                    (1, 'HH:mm:ss'),
                    (2, 'HH:mm:ss:SSSS'),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                _RadioLabel('日期和时间'),
                _RadioGroup<int>(
                  value: _dayTime,
                  onChanged: (v) => setState(() => _dayTime = v),
                  options: const [
                    (0, '00:00:00（24小时制）'),
                    (1, '00:00 下午（12小时制）'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {},
            style: RuQiButtonStyles.primary(context),
            child: const Text('保存修改'),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RadioLabel extends StatelessWidget {
  const _RadioLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RadioGroup<T> extends StatelessWidget {
  const _RadioGroup({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String)> options;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: value,
      onChanged: (v) {
        if (v != null) {
          onChanged(v);
        }
      },
      child: Column(
        children: [
          for (final (v, label) in options)
            RadioListTile<T>(
              value: v,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(label),
            ),
        ],
      ),
    );
  }
}
