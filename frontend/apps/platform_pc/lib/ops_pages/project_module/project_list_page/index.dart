import 'package:flutter/material.dart';

import '../../operations_action_dialog.dart';
import '../project_settings_page/index.dart';

/// 租户项目（运营后台）——业务静态页。
class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('租户项目')),
      body: const ProjectListBody(),
    );
  }
}

/// 租户项目正文（供运营后台对话框右侧内容区内嵌展示）。
class ProjectListBody extends StatelessWidget {
  const ProjectListBody({super.key});

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
                  hintText: '搜索项目名称',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('新建项目'),
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
                DataColumn(label: Text('项目名称')),
                DataColumn(label: Text('所属租户')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: [
                _row(context, '官网门户', '星云科技有限公司', '运行中', '2024-06-01 10:00'),
                _row(context, '商城小程序', '蓝海贸易有限公司', '运行中', '2024-06-15 14:30'),
                _row(
                  context,
                  '内部 OA 系统',
                  '星云科技有限公司',
                  '已停用',
                  '2024-03-20 09:12',
                ),
                _row(
                  context,
                  '数据分析平台',
                  '恒信金融服务有限公司',
                  '运行中',
                  '2024-07-02 16:45',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _row(
    BuildContext context,
    String name,
    String tenant,
    String status,
    String time,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(tenant)),
        DataCell(Text(status)),
        DataCell(Text(time)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('查看'),
              ),
              TextButton(
                onPressed: () => showOperationsActionDialog(
                  context,
                  title: '项目设置',
                  child: const ProjectSettingsBody(),
                ),
                child: const Text('设置'),
              ),
              TextButton(onPressed: () {}, child: const Text('删除')),
            ],
          ),
        ),
      ],
    );
  }
}
