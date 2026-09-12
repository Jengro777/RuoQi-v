import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';

import 'user_confirm_dialog.dart';

/// 停用账户确认（对应 停用账户 原型）。
Future<bool> showDeactivateConfirmDialog(
  BuildContext context,
  UserAccount user,
) {
  return showUserConfirmDialog(
    context,
    title: '停用 ${user.displayName} 的账户？',
    content: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('· 停用的账号将无法登录应用以及重置密码'),
        SizedBox(height: RuQiSpacing.xxs),
        Text('· 停用账号期间，仍可编辑用户信息'),
        SizedBox(height: RuQiSpacing.xxs),
        Text('· 停用账号可以恢复'),
      ],
    ),
    confirmLabel: '停用',
    destructive: true,
  );
}
