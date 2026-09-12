import 'package:flutter/material.dart';

import '../../operations_action_dialog.dart';
import '../../shared/audit_dialogs/audit_detail_dialog.dart';
import '../../shared/audit_dialogs/audit_form_optional_dialog.dart';
import '../../shared/audit_dialogs/audit_form_required_dialog.dart';

/// 变更审核（运营后台）——业务静态页。
class SubscriptionChangeAuditPage extends StatelessWidget {
  const SubscriptionChangeAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('变更审核')),
      body: const SubscriptionChangeAuditBody(),
    );
  }
}

/// 变更审核正文（供运营后台对话框右侧内容区内嵌展示）。
class SubscriptionChangeAuditBody extends StatelessWidget {
  const SubscriptionChangeAuditBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _auditCard(
          context,
          '星云科技有限公司',
          '标准版 ¥499/月 → 专业版 ¥999/月',
          '2024-08-18 14:05',
        ),
        _auditCard(
          context,
          '蓝海贸易有限公司',
          '专业版 ¥999/月 → 旗舰版 ¥1999/月',
          '2024-08-17 11:30',
        ),
        _auditCard(
          context,
          '晨曦教育科技有限公司',
          '标准版 ¥499/月 → 标准版 ¥499/月（续费）',
          '2024-08-16 16:20',
        ),
      ],
    );
  }

  Widget _auditCard(
    BuildContext context,
    String tenant,
    String change,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(tenant),
        subtitle: Text('$change · $time'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核详情',
                child: const AuditDetailDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('查看'),
            ),
            FilledButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核',
                child: const AuditFormOptionalDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('通过'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核',
                child: const AuditFormRequiredDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('拒绝'),
            ),
          ],
        ),
      ),
    );
  }
}
