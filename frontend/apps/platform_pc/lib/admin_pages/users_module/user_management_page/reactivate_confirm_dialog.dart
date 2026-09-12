import 'package:flutter/material.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';

import 'user_confirm_dialog.dart';

/// 重新激活确认（对应 重新激活 原型）。
Future<bool> showReactivateConfirmDialog(
  BuildContext context,
  UserAccount user,
) {
  return showUserConfirmDialog(
    context,
    title: '重新激活 ${user.displayName}？',
    content: const Text('账户将被允许再次登录，并被放回账户被停用前所在的组。'),
    confirmLabel: '重新激活',
  );
}
