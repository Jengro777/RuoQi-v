import 'package:flutter/material.dart';

/// 租户列表（运营后台）——业务静态页。
class TenantListPage extends StatelessWidget {
  const TenantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('租户列表')),
      body: const TenantListBody(),
    );
  }
}

/// 租户列表正文（供运营后台对话框右侧内容区内嵌展示）。
class TenantListBody extends StatelessWidget {
  const TenantListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索租户名称',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            for (final status in const ['全部', '活跃', '已锁定'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status),
                  selected: status == '全部',
                  onSelected: (_) {},
                ),
              ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('租户名称')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: [
                _row(context, '星云科技有限公司', '活跃', '2024-05-12 09:30'),
                _row(context, '蓝海贸易有限公司', '活跃', '2024-05-11 16:42'),
                _row(context, '云端网络工作室', '已锁定', '2024-04-28 11:05'),
                _row(context, '恒信金融服务有限公司', '活跃', '2024-04-15 14:20'),
                _row(context, '晨曦教育科技有限公司', '已锁定', '2024-03-30 10:18'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '共 23 条，第 1 / 5 页',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            OutlinedButton(onPressed: () {}, child: const Text('上一页')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () {}, child: const Text('下一页')),
          ],
        ),
      ],
    );
  }

  DataRow _row(BuildContext context, String name, String status, String time) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(status)),
        DataCell(Text(time)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('--'),
            ],
          ),
        ),
      ],
    );
  }
}
