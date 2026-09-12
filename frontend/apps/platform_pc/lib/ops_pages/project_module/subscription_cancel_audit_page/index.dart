import 'package:flutter/material.dart';

import '../../operations_action_dialog.dart';
import '../../shared/audit_dialogs/audit_form_optional_dialog.dart';
import '../../shared/audit_dialogs/audit_form_required_dialog.dart';

/// 退订审核（运营后台）——业务静态页。
class SubscriptionCancelAuditPage extends StatelessWidget {
  const SubscriptionCancelAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('退订审核')),
      body: const SubscriptionCancelAuditBody(),
    );
  }
}

/// 退订审核正文（供运营后台对话框右侧内容区内嵌展示）。
class SubscriptionCancelAuditBody extends StatelessWidget {
  const SubscriptionCancelAuditBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _auditCard(
          context,
          '宏图物流有限公司',
          '专业版 ¥999/月 · 到期日 2024-09-12',
          '2024-08-18 09:40',
        ),
        _auditCard(
          context,
          '云端网络工作室',
          '标准版 ¥499/月 · 到期日 2024-08-30',
          '2024-08-17 17:25',
        ),
      ],
    );
  }

  Widget _auditCard(
    BuildContext context,
    String tenant,
    String plan,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(tenant),
        subtitle: Text('$plan · $time'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核',
                child: const AuditFormOptionalDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('同意退订'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核',
                child: const AuditFormRequiredDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('驳回'),
            ),
          ],
        ),
      ),
    );
  }
}
