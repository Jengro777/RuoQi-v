import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/status_badge.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/logs_common.dart';

/// 支付日志。
class PaymentLog {
  const PaymentLog({
    required this.orderNo,
    required this.bizType,
    required this.method,
    required this.provider,
    required this.amount,
    required this.status,
    required this.paidAt,
  });

  final String orderNo;
  final String bizType;
  final String method;
  final String provider;
  final String amount;
  final String status;
  final String paidAt;
}

const paymentLogs = [
  PaymentLog(orderNo: '202236565465466546', bizType: '保证金充值', method: '微信', provider: '腾讯', amount: '100.00 GHS', status: '成功', paidAt: '2023-01-16T08:33:24+08:00'),
  PaymentLog(orderNo: '202236565465466547', bizType: '订阅付费', method: '支付宝', provider: '阿里', amount: '50.00 CNY', status: '成功', paidAt: '2023-01-16T08:20:11+08:00'),
  PaymentLog(orderNo: '202236565465466548', bizType: '广告充值', method: 'Apple', provider: 'Apple', amount: '20.00 USD', status: '失败', paidAt: '2023-01-15T22:11:00+08:00'),
  PaymentLog(orderNo: '202236565465466549', bizType: '订单退款', method: 'Card', provider: 'Strip', amount: '30.00 USD', status: '成功', paidAt: '2023-01-15T20:05:00+08:00'),
  PaymentLog(orderNo: '202236565465466550', bizType: '钱包重置', method: 'MOMO', provider: 'MTN', amount: '10.00 GHS', status: '成功', paidAt: '2023-01-15T19:40:00+08:00'),
];

/// 日志-支付日志 业务正文（对应 支付日志 原型）。
class PaymentLogsBody extends StatefulWidget {
  const PaymentLogsBody({super.key});

  @override
  State<PaymentLogsBody> createState() => _PaymentLogsBodyState();
}

class _PaymentLogsBodyState extends State<PaymentLogsBody> {
  String _query = '';

  List<PaymentLog> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return paymentLogs;
    return [
      for (final log in paymentLogs)
        if (log.orderNo.contains(q) ||
            log.bizType.contains(q) ||
            log.method.contains(q) ||
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
          title: '支付日志',
          description: '查看平台支付与退款流水记录。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        LogFilterBar(onQueryChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '支付单号', flex: 18),
            (label: '业务类型', flex: 10),
            (label: '支付方式', flex: 9),
            (label: '服务商', flex: 9),
            (label: '计费金额(币种)', flex: 13),
            (label: '状态', flex: 8),
            (label: '付款时间', flex: 16),
          ],
          rowCount: _filtered.length,
          emptyText: '无匹配日志',
          rowBuilder: (context, index) {
            final log = _filtered[index];
            return [
              CellText(log.orderNo, strong: true),
              CellText(log.bizType),
              CellText(log.method, muted: true),
              CellText(log.provider, muted: true),
              CellText(log.amount, muted: true),
              StatusBadge(
                label: log.status,
                tone: log.status == '成功'
                    ? StatusTone.success
                    : StatusTone.error,
              ),
              CellText(log.paidAt, muted: true),
            ];
          },
        ),
        const SizedBox(height: RuQiSpacing.md),
        UserPagination(total: 89),
      ],
    );
  }
}
