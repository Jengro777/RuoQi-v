import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_models.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'user_common.dart';

/// ID / 账号 / 用户名 字段说明（账号字段旁的 tips 弹窗内容）。
const accountFieldTips = (
  title: 'ID / 账号 / 用户名 说明',
  sections: <TipsSection>[
    (
      title: 'ID',
      items: [
        '组合方式：开发人员自定义',
        '变更方式：系统自动生成，此 ID 作为用户数据关联的唯一凭据，一旦生成不可变化（不作为登录凭据）',
        '可见性：系统不可见，仅存于数据库中',
      ],
    ),
    (
      title: '账号',
      items: [
        '组合方式：由数字、字母、符号组合而成，一般不支持中文（一般限制不得小于 6 位）',
        '变更方式：账号一旦生成，不可随意变更（可以变更，不支持频繁变更）（可登录）',
        '可见性：账号只供使用者个人自己使用，他人不可见',
      ],
    ),
    (
      title: '用户名',
      items: [
        '组合方式：可以由文字、数字、字母、符号组合而成，支持中文',
        '变更方式：用户名生成后，可以随意变更（可登录）',
        '可见性：用户名供使用者个人自己使用，他人可见其用户名名称',
      ],
    ),
  ],
);

/// 打开编辑用户面板。
Future<void> showEditUserPanel(BuildContext context, UserAccount user) {
  return showSystemSettingsPanel(
    context,
    title: '编辑用户',
    child: EditUserForm(user: user),
  );
}

/// 编辑用户表单：名 / 姓 / 账号 / 电子邮件 + 元信息。
class EditUserForm extends StatefulWidget {
  const EditUserForm({super.key, required this.user});

  final UserAccount user;

  @override
  State<EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _account;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user.name);
    _lastName = TextEditingController(text: widget.user.surname);
    _account = TextEditingController(text: widget.user.account);
    _email = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _account.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstName,
                        decoration: const InputDecoration(labelText: '名'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lastName,
                        decoration: const InputDecoration(labelText: '姓'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _account,
                        decoration: const InputDecoration(
                          labelText: '账号',
                          helperText: '登录账号，如 admin : main',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.xs),
                    UserTipsButton(
                      title: accountFieldTips.title,
                      sections: accountFieldTips.sections,
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '电子邮件'),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const Divider(height: 1),
                const SizedBox(height: RuQiSpacing.md),
                UserMetaRow(label: '创建', value: 'system · 3/29/2022 10:04:32'),
                const SizedBox(height: RuQiSpacing.xs),
                UserMetaRow(label: '最后编辑', value: 'account001'),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '更新',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
