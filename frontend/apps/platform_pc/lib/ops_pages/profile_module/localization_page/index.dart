import 'package:flutter/material.dart';

/// 本地化（运营后台·个人中心）——业务静态页。
class LocalizationPage extends StatelessWidget {
  const LocalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('本地化')),
      body: const LocalizationBody(),
    );
  }
}

/// 本地化正文（供运营后台对话框右侧内容区内嵌展示）。
class LocalizationBody extends StatelessWidget {
  const LocalizationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '显示设置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '界面语言',
                  child: DropdownMenu<String>(
                    initialSelection: '简体中文',
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: '简体中文', label: '简体中文'),
                      DropdownMenuEntry(value: 'English', label: 'English'),
                      DropdownMenuEntry(value: '日本語', label: '日本語'),
                    ],
                    onSelected: (_) {},
                    expandedInsets: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '时区',
                  child: DropdownMenu<String>(
                    initialSelection: 'Asia/Shanghai (UTC+8)',
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: 'Asia/Shanghai (UTC+8)',
                        label: 'Asia/Shanghai (UTC+8)',
                      ),
                      DropdownMenuEntry(value: 'UTC', label: 'UTC'),
                      DropdownMenuEntry(
                        value: 'Europe/London (UTC+0)',
                        label: 'Europe/London (UTC+0)',
                      ),
                    ],
                    onSelected: (_) {},
                    expandedInsets: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '货币',
                  child: DropdownMenu<String>(
                    initialSelection: 'CNY ¥',
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'CNY ¥', label: '人民币 (CNY ¥)'),
                      DropdownMenuEntry(value: 'USD \$', label: '美元 (USD \$)'),
                      DropdownMenuEntry(value: 'EUR €', label: '欧元 (EUR €)'),
                    ],
                    onSelected: (_) {},
                    expandedInsets: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '日期格式',
                  child: const TextField(
                    decoration: InputDecoration(hintText: 'YYYY-MM-DD'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '数字格式',
                  child: const TextField(
                    decoration: InputDecoration(hintText: '1,234,567.89'),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(label),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
