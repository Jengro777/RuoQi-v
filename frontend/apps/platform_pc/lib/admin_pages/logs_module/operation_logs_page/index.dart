import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/logs_common.dart';

/// 操作日志。
class OperationLog {
  const OperationLog({
    required this.id,
    required this.account,
    required this.eventType,
    required this.eventDetail,
    required this.path,
    required this.method,
    required this.ip,
    required this.time,
    required this.result,
  });

  final String id;
  final String account;
  final String eventType;
  final String eventDetail;
  final String path;
  final String method;
  final String ip;
  final String time;
  final String result;
}

const operationLogs = [
  OperationLog(id: '1', account: 'account2 : main', eventType: '查询', eventDetail: '查询当前站点货币信息', path: '/base/rate/findSiteCurrency', method: 'GET', ip: '10.52.59.176 240e::0001', time: '2023-01-16T08:33:24+08:00', result: '200 成功'),
  OperationLog(id: '2', account: 'account2 : sub', eventType: '编辑事件', eventDetail: '修改2020202订单金额', path: '/dict/inner/type', method: 'POST', ip: '10.52.59.176', time: '2023-01-16T08:20:11+08:00', result: '200 成功'),
  OperationLog(id: '3', account: 'account2', eventType: '查询', eventDetail: '--', path: '/dict/locale', method: 'GET', ip: '240e::0001', time: '2023-01-16T07:55:00+08:00', result: '200 成功'),
];

/// 日志-操作日志 业务正文（对应 操作日志 原型）。
class OperationLogsBody extends StatefulWidget {
  const OperationLogsBody({super.key});

  @override
  State<OperationLogsBody> createState() => _OperationLogsBodyState();
}

class _OperationLogsBodyState extends State<OperationLogsBody> {
  String _query = '';

  List<OperationLog> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return operationLogs;
    return [
      for (final log in operationLogs)
        if (log.account.contains(q) ||
            log.path.contains(q) ||
            log.eventDetail.contains(q) ||
            log.id.contains(q))
          log,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '操作日志',
          description: '查看管理员在后台的关键操作记录。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        LogFilterBar(onQueryChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'ID', flex: 6),
            (label: '用户账号', flex: 13),
            (label: '事件类型', flex: 9),
            (label: '事件详情', flex: 14),
            (label: '访问路径', flex: 16),
            (label: '访问方式', flex: 8),
            (label: 'IP', flex: 13),
            (label: '操作时间', flex: 15),
            (label: '事件结果', flex: 9),
          ],
          rowCount: _filtered.length,
          emptyText: '无匹配日志',
          rowBuilder: (context, index) {
            final log = _filtered[index];
            return [
              CellText(log.id, strong: true),
              CellText(log.account),
              CellText(log.eventType, muted: true),
              CellText(log.eventDetail, muted: true),
              CellText(log.path, muted: true),
              CellText(log.method, muted: true),
              CellText(log.ip, muted: true),
              CellText(log.time, muted: true),
              StatusBadge(
                label: log.result,
                tone: StatusTone.success,
              ),
            ];
          },
        ),
        const SizedBox(height: RuQiSpacing.md),
        UserPagination(total: 1240),
      ],
    );
  }
}
