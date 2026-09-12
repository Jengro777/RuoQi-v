import 'package:flutter/material.dart';

/// 租户设置（运营后台）——业务静态页。
class TenantSettingsPage extends StatelessWidget {
  const TenantSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('租户设置')),
      body: const TenantSettingsBody(),
    );
  }
}

/// 租户设置正文（供运营后台对话框右侧内容区内嵌展示）。
class TenantSettingsBody extends StatelessWidget {
  const TenantSettingsBody({super.key});

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
                  label: '租户名称',
                  child: const TextField(
                    decoration: InputDecoration(hintText: '星云科技有限公司'),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '租户描述',
                  child: const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '用于 IAM 登录的云服务平台',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '所属域名',
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'xingyun.example.com',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: '时区',
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Asia/Shanghai',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Asia/Shanghai',
                        child: Text('Asia/Shanghai (UTC+8)'),
                      ),
                      DropdownMenuItem(value: 'UTC', child: Text('UTC')),
                      DropdownMenuItem(
                        value: 'Europe/London',
                        child: Text('Europe/London (UTC+0)'),
                      ),
                    ],
                    onChanged: null,
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
