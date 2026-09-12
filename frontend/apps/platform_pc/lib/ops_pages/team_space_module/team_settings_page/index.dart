import 'package:flutter/material.dart';

/// 团队设置（运营后台）——业务静态页。
class TeamSettingsPage extends StatelessWidget {
  const TeamSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('团队设置')),
      body: const TeamSettingsBody(),
    );
  }
}

/// 团队设置正文（供运营后台对话框右侧内容区内嵌展示）。
class TeamSettingsBody extends StatelessWidget {
  const TeamSettingsBody({super.key});

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
                  '基本信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '团队名称',
                  child: const TextField(
                    decoration: InputDecoration(hintText: '星云研发团队'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '团队描述',
                  child: const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '负责公司内部系统研发与运维',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '默认角色',
                  child: DropdownMenu<String>(
                    initialSelection: '成员',
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: '团队负责人', label: '团队负责人'),
                      DropdownMenuEntry(value: '成员', label: '成员'),
                      DropdownMenuEntry(value: '访客', label: '访客'),
                    ],
                    onSelected: (_) {},
                    expandedInsets: EdgeInsets.zero,
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
