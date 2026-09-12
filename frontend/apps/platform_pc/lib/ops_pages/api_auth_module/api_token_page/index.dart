import 'package:flutter/material.dart';

/// API Token（运营后台）——业务静态页。
class ApiTokenPage extends StatelessWidget {
  const ApiTokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Token')),
      body: const ApiTokenBody(),
    );
  }
}

/// API Token 正文（供运营后台对话框右侧内容区内嵌展示）。
class ApiTokenBody extends StatelessWidget {
  const ApiTokenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              '用于 OpenAPI 调用的访问令牌，请妥善保管。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('新建 Token'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('名称')),
                DataColumn(label: Text('Key')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('最后使用')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: [
                _row(
                  '生产环境',
                  'rkp_live_****3f2a',
                  '2024-06-01',
                  '2024-08-18',
                  '启用',
                ),
                _row(
                  '测试环境',
                  'rkp_test_****9b17',
                  '2024-06-15',
                  '2024-08-10',
                  '启用',
                ),
                _row(
                  '数据同步',
                  'rkp_live_****c4e8',
                  '2024-04-02',
                  '2024-07-01',
                  '已禁用',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _row(
    String name,
    String key,
    String created,
    String used,
    String status,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(key)),
        DataCell(Text(created)),
        DataCell(Text(used)),
        DataCell(Text(status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: () {}, child: const Text('禁用')),
              TextButton(onPressed: () {}, child: const Text('删除')),
            ],
          ),
        ),
      ],
    );
  }
}
