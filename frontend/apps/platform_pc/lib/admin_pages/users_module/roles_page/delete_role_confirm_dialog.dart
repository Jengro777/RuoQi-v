import 'package:flutter/material.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/users_module/user_management_page/user_confirm_dialog.dart';

/// 删除角色组确认（对应 删除角色组 原型）。
Future<bool> showDeleteRoleConfirmDialog(
  BuildContext context,
  RoleGroup role,
) {
  return showUserConfirmDialog(
    context,
    title: '删除这个角色组？',
    content: Text(
      '确定删除吗？ 该组所有成员都将丢失该组下的权限设置。'
      '此操作不可逆。（${role.name}）',
    ),
    confirmLabel: '是',
    destructive: true,
  );
}
