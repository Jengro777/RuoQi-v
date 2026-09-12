import 'package:flutter/material.dart';

/// 租户团队（运营后台）——业务静态页。
class TeamSpacePage extends StatelessWidget {
  const TeamSpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('租户团队')),
      body: const TeamSpaceBody(),
    );
  }
}

/// 租户团队正文（供运营后台对话框右侧内容区内嵌展示）。
class TeamSpaceBody extends StatelessWidget {
  const TeamSpaceBody({super.key});

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
                  hintText: '搜索成员',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Text('添加成员'),
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
                DataColumn(label: Text('成员')),
                DataColumn(label: Text('所属租户')),
                DataColumn(label: Text('角色')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: [
                _row(context, '张伟', '星云科技有限公司', '团队负责人', '活跃'),
                _row(context, '李娜', '星云科技有限公司', '成员', '活跃'),
                _row(context, '王强', '蓝海贸易有限公司', '成员', '活跃'),
                _row(context, '赵敏', '星云科技有限公司', '成员', '已停用'),
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
    String role,
    String status,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(tenant)),
        DataCell(Text(role)),
        DataCell(Text(status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('查看'),
              ),
              TextButton(onPressed: () {}, child: const Text('设置角色')),
              TextButton(onPressed: () {}, child: const Text('移除')),
            ],
          ),
        ),
      ],
    );
  }
}
