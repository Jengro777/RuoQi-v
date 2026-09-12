import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/logs_common.dart';

/// 登录日志。
class LoginLog {
  const LoginLog({
    required this.id,
    required this.account,
    required this.method,
    required this.ip,
    required this.browser,
    required this.os,
    required this.location,
    required this.time,
  });

  final String id;
  final String account;
  final String method;
  final String ip;
  final String browser;
  final String os;
  final String location;
  final String time;
}

const loginLogs = [
  LoginLog(id: '1', account: 'account1:main', method: '账密', ip: '10.52.59.176', browser: 'Chrome 103.0.0', os: 'Windows10', location: '中国-广东-深圳-福田区', time: '2023-01-16T08:33:24+08:00'),
  LoginLog(id: '2', account: 'account2:sub', method: '手机密码', ip: '240e::0001', browser: 'Edge 102.0.1245', os: 'Mac OS X 10.15.7', location: '中国-广东-深圳-福田区', time: '2023-01-16T08:30:10+08:00'),
  LoginLog(id: '3', account: 'account1:main', method: '邮箱密码', ip: '10.52.59.176', browser: 'Chrome 103.0.0', os: 'Ipad 15', location: '中国-广东-深圳-南山区', time: '2023-01-15T22:11:00+08:00'),
  LoginLog(id: '4', account: 'account2:sub', method: 'Google授权', ip: '240e::0001', browser: 'Chrome 103.0.0', os: 'deepin 20.3', location: '中国-广东-深圳-福田区', time: '2023-01-15T20:05:00+08:00'),
  LoginLog(id: '5', account: 'account1:main', method: '手机验证码', ip: '10.52.59.176', browser: 'Chrome 103.0.0', os: 'Iphone 14', location: '中国-广东-深圳-福田区', time: '2023-01-15T19:40:00+08:00'),
];

/// 日志-登录日志 业务正文（对应 登录日志 原型）。
class LoginLogsBody extends StatefulWidget {
  const LoginLogsBody({super.key});

  @override
  State<LoginLogsBody> createState() => _LoginLogsBodyState();
}

class _LoginLogsBodyState extends State<LoginLogsBody> {
  String _query = '';

  List<LoginLog> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return loginLogs;
    return [
      for (final log in loginLogs)
        if (log.account.contains(q) ||
            log.method.contains(q) ||
            log.location.contains(q) ||
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
          title: '登录日志',
          description: '查看用户与管理员的登录记录。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        LogFilterBar(onQueryChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'ID', flex: 6),
            (label: '登录账号', flex: 13),
            (label: '登录方式', flex: 10),
            (label: 'IP', flex: 12),
            (label: '浏览器', flex: 13),
            (label: '操作系统', flex: 13),
            (label: '登录地点', flex: 14),
            (label: '登录时间', flex: 15),
          ],
          rowCount: _filtered.length,
          emptyText: '无匹配日志',
          rowBuilder: (context, index) {
            final log = _filtered[index];
            return [
              CellText(log.id, strong: true),
              CellText(log.account),
              CellText(log.method, muted: true),
              CellText(log.ip, muted: true),
              CellText(log.browser, muted: true),
              CellText(log.os, muted: true),
              CellText(log.location, muted: true),
              CellText(log.time, muted: true),
            ];
          },
        ),
        const SizedBox(height: RuQiSpacing.md),
        UserPagination(total: 356),
      ],
    );
  }
}
