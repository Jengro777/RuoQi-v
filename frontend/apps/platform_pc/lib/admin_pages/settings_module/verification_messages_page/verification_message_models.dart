/// 验证消息设置项。
class VerificationMessageItem {
  const VerificationMessageItem({
    required this.name,
    required this.description,
    required this.subject,
    required this.sender,
    required this.emailBody,
    required this.sceneVariables,
    this.sms,
  });

  final String name;
  final String description;

  /// 主题（邀请用户为「我们邀请您加入 ${Site Name}」）。
  final String subject;

  /// 发件人。
  final String sender;

  /// 电子邮件正文模板。
  final String emailBody;

  /// 场景变量说明，如「用户账号：\${user_account}」。
  final List<String> sceneVariables;

  /// 短信渠道配置；`null` 表示该消息仅通过邮件发送。
  final VerificationSmsChannels? sms;
}

/// 短信渠道：腾讯云 / 阿里云 / Arkesel。
class VerificationSmsChannels {
  const VerificationSmsChannels({
    required this.tencentTemplateId,
    required this.aliyunTemplateId,
    required this.smsBody,
  });

  final String tencentTemplateId;
  final String aliyunTemplateId;

  /// Arkesel 直接编写的短信内容。
  final String smsBody;
}

const _emailBody =
    'Your \${Site Name} verification code is \${verification code} , '
    'Valid within 15 minutes. Please do disclose to anyobne.\n'
    'Identification code: \${Identification code}. \n';

const _smsBody =
    '\${Site Name} Verification code:  \${verification code} '
    'from \${Site Name},valid for 15 minutes.Please do not disclose it to '
    'anyone.\nIdentification code: \${Identification code}';

const _userAccountVar = '用户账号：\${user_account}';

/// 验证消息设置项列表（对应 设置-验证消息 原型）。
const verificationMessageItems = [
  VerificationMessageItem(
    name: '验证码登录',
    description: '用户使用验证码登录时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '注册验证',
    description: '用户注册验证时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '2566',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '修改密码验证',
    description: '用户修改密码时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '2566',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '密码重置验证',
    description: '用户重置密码时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '2566',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '邀请用户',
    description: '邀请用户时，发送的通知消息',
    subject: '我们邀请您加入 \${Site Name}',
    sender: 'Avey<avey777@163.com>',
    emailBody:
        '\${user_nick} wants to join them on \${Site Name}\n'
        'Identification code: \${Identification code}. \n',
    sceneVariables: [
      _userAccountVar,
      '用户昵称：\${user_nick}',
      '网站名称：\${Site Name}',
      '邀请链接：\${Invite Link}',
    ],
  ),
];
