import 'package:flutter/material.dart';

/// 成员管理（运营后台）——业务静态页。
class MemberManagePage extends StatelessWidget {
  const MemberManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成员管理')),
      body: const MemberManageBody(),
    );
  }
}

/// 成员管理正文（供运营后台对话框右侧内容区内嵌展示）。
class MemberManageBody extends StatelessWidget {
  const MemberManageBody({super.key});

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
                  hintText: '搜索成员姓名或邮箱',
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
              label: const Text('邀请成员'),
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
                DataColumn(label: Text('邮箱')),
                DataColumn(label: Text('角色')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('操作')),
              ],
              rows: [
                _row('张伟', 'zhangwei@example.com', '管理员', '活跃'),
                _row('李娜', 'lina@example.com', '成员', '活跃'),
                _row('王强', 'wangqiang@example.com', '成员', '已停用'),
                _row('赵敏', 'zhaomin@example.com', '成员', '活跃'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _row(String name, String email, String role, String status) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(email)),
        DataCell(Text(role)),
        DataCell(Text(status)),
        DataCell(TextButton(onPressed: () {}, child: const Text('移除'))),
      ],
    );
  }
}
