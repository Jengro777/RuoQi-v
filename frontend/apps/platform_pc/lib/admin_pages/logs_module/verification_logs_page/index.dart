import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/logs_common.dart';

/// 验证日志。
class VerificationLog {
  const VerificationLog({
    required this.id,
    required this.type,
    required this.target,
    required this.codeOrLink,
    required this.validity,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String target;
  final String codeOrLink;
  final String validity;
  final String status;
  final String createdAt;
}

const verificationLogs = [
  VerificationLog(id: '0453', type: '登录验证码', target: '+86 15020579521', codeOrLink: '452354', validity: '5 min', status: '有效', createdAt: '2023-01-16T08:33:24+08:00'),
  VerificationLog(id: '1005', type: '注册验证码', target: 'm4@163.com', codeOrLink: '252525', validity: '15 min', status: '有效', createdAt: '2023-01-16T08:33:24+08:00'),
  VerificationLog(id: '4251', type: '密码重置链接', target: 'm4@163.com', codeOrLink: 'https://pwsreset.com', validity: '48 h', status: '有效', createdAt: '2023-01-16T08:33:24+08:00'),
  VerificationLog(id: '5476', type: '邀请链接', target: 'm4@163.com', codeOrLink: 'https://invitation.com', validity: '48 h', status: '已失效', createdAt: '2023-01-15T10:12:00+08:00'),
  VerificationLog(id: '5723', type: '注册验证码', target: '+86 15020579521', codeOrLink: '7824', validity: '5 min', status: '有效', createdAt: '2023-01-15T09:30:00+08:00'),
];

/// 日志-验证日志 业务正文（对应 验证日志 原型）。
class VerificationLogsBody extends StatefulWidget {
  const VerificationLogsBody({super.key});

  @override
  State<VerificationLogsBody> createState() => _VerificationLogsBodyState();
}

class _VerificationLogsBodyState extends State<VerificationLogsBody> {
  String _query = '';

  List<VerificationLog> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return verificationLogs;
    return [
      for (final log in verificationLogs)
        if (log.id.contains(q) ||
            log.type.contains(q) ||
            log.target.contains(q) ||
            log.status.contains(q))
          log,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '验证日志',
          description: '查看验证码与验证链接的发送与失效记录。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        LogFilterBar(onQueryChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'ID', flex: 7),
            (label: '类型', flex: 10),
            (label: '邮件/手机号', flex: 16),
            (label: '验证码/验证链接', flex: 20),
            (label: '效期', flex: 8),
            (label: '状态', flex: 8),
            (label: '生成时间', flex: 16),
          ],
          rowCount: _filtered.length,
          emptyText: '无匹配日志',
          rowBuilder: (context, index) {
            final log = _filtered[index];
            return [
              CellText(log.id, strong: true),
              CellText(log.type),
              CellText(log.target, muted: true),
              CellText(log.codeOrLink, muted: true),
              CellText(log.validity, muted: true),
              StatusBadge(
                label: log.status,
                tone: log.status == '有效'
                    ? StatusTone.success
                    : StatusTone.neutral,
              ),
              CellText(log.createdAt, muted: true),
            ];
          },
        ),
        const SizedBox(height: RuQiSpacing.md),
        UserPagination(total: 268),
      ],
    );
  }
}
