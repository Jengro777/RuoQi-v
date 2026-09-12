import 'package:flutter/material.dart';

import '../../operations_action_dialog.dart';
import '../../shared/audit_dialogs/audit_form_optional_dialog.dart';
import '../../shared/audit_dialogs/audit_form_required_dialog.dart';

/// (订阅)开通审核（运营后台）——业务静态页。
class SubscriptionOpenAuditPage extends StatelessWidget {
  const SubscriptionOpenAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('(订阅)开通审核')),
      body: const SubscriptionOpenAuditBody(),
    );
  }
}

/// (订阅)开通审核正文（供运营后台对话框右侧内容区内嵌展示）。
class SubscriptionOpenAuditBody extends StatelessWidget {
  const SubscriptionOpenAuditBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _auditCard(context, '星云科技有限公司', '专业版 · ¥999/月', '2024-08-18 10:24'),
        _auditCard(context, '宏图物流有限公司', '标准版 · ¥499/月', '2024-08-17 15:40'),
        _auditCard(context, '绿源环保科技有限公司', '专业版 · ¥999/月', '2024-08-16 09:12'),
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
