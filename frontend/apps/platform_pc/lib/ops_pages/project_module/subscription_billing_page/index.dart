import 'package:flutter/material.dart';

/// 订阅计费（运营后台）——业务静态页。
class SubscriptionBillingPage extends StatelessWidget {
  const SubscriptionBillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订阅计费')),
      body: const SubscriptionBillingBody(),
    );
  }
}

/// 订阅计费正文（供运营后台对话框右侧内容区内嵌展示）。
class SubscriptionBillingBody extends StatelessWidget {
  const SubscriptionBillingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '专业版',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('¥ 999 / 月'),
                      const SizedBox(height: 8),
                      Text(
                        '到期时间：2025-03-12 · 自动续费',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Chip(label: Text('已开通')),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: () {}, child: const Text('变更套餐')),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: () {}, child: const Text('续费')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('计费记录', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('时间')),
                DataColumn(label: Text('项目')),
                DataColumn(label: Text('金额')),
                DataColumn(label: Text('状态')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('2024-08-12')),
                    DataCell(Text('官网门户')),
                    DataCell(Text('¥ 999.00')),
                    DataCell(Text('已支付')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('2024-07-12')),
                    DataCell(Text('官网门户')),
                    DataCell(Text('¥ 999.00')),
                    DataCell(Text('已支付')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('2024-06-12')),
                    DataCell(Text('官网门户')),
                    DataCell(Text('¥ 999.00')),
                    DataCell(Text('已支付')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
