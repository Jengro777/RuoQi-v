import 'package:flutter/material.dart';

/// 项目设置（运营后台）——业务静态页。
class ProjectSettingsPage extends StatelessWidget {
  const ProjectSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('项目设置')),
      body: const ProjectSettingsBody(),
    );
  }
}

/// 项目设置正文（供运营后台对话框右侧内容区内嵌展示）。
class ProjectSettingsBody extends StatelessWidget {
  const ProjectSettingsBody({super.key});

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
                  label: '项目名称',
                  child: const TextField(
                    decoration: InputDecoration(hintText: '官网门户'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '项目 Key',
                  child: const TextField(
                    decoration: InputDecoration(hintText: 'web-portal'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '项目描述',
                  child: const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '对外展示的公司官网门户',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '所属租户',
                  child: const TextField(
                    enabled: false,
                    decoration: InputDecoration(hintText: '星云科技有限公司'),
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
