import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 设置-电子邮件 业务正文（替换静态原型复刻页）。
class EmailSettingsBody extends StatefulWidget {
  const EmailSettingsBody({super.key});

  @override
  State<EmailSettingsBody> createState() => _EmailSettingsBodyState();
}

class _EmailSettingsBodyState extends State<EmailSettingsBody> {
  int _security = 0; // None / SSL / TLS / STARTTLS
  final _smtpAddress = TextEditingController(text: 'smtp.yourservice.com');
  final _smtpPort = TextEditingController(text: '587');
  final _smtpUsername = TextEditingController(text: 'nicetoseeyou');
  final _smtpPassword = TextEditingController(text: 'password');
  final _senderName = TextEditingController(text: 'CIAM');
  final _senderAddress = TextEditingController(text: 'email@yourcompany.com');
  final _replyAddress = TextEditingController(
    text: 'email-replies@yourcompany.com',
  );
  final _testContent = TextEditingController(
    text: 'Your \${Site Name} emails are working — hooray!',
  );

  @override
  void dispose() {
    _smtpAddress.dispose();
    _smtpPort.dispose();
    _smtpUsername.dispose();
    _smtpPassword.dispose();
    _senderName.dispose();
    _senderAddress.dispose();
    _replyAddress.dispose();
    _testContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        _Header(title: '电子邮件', description: 'SMTP 服务器与发件人配置。'),
        const SizedBox(height: RuQiSpacing.lg),
        _SectionCard(
          title: 'SMTP 服务器',
          children: [
            TextField(
              controller: _smtpAddress,
              decoration: const InputDecoration(
                labelText: 'SMTP地址',
                helperText: 'SMTP 服务器地址，用于用户邀请、密码重置。',
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _smtpPort,
              decoration: const InputDecoration(
                labelText: 'SMTP端口',
                helperText: '你的 SMTP 服务器用于发送邮件的端口。',
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            _RadioLabel('SMTP安全'),
            RadioGroup<int>(
              groupValue: _security,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _security = value);
                }
              },
              child: Column(
                children: [
                  for (final (i, label) in const [
                    (0, 'None'),
                    (1, 'SSL'),
                    (2, 'TLS'),
                    (3, 'STARTTLS'),
                  ])
                    RadioListTile<int>(
                      value: i,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(label),
                    ),
                ],
              ),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            TextField(
              controller: _smtpUsername,
              decoration: const InputDecoration(labelText: 'SMTP用户名'),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _smtpPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'SMTP密码'),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.md),
        _SectionCard(
          title: '发件人',
          children: [
            TextField(
              controller: _senderName,
              decoration: const InputDecoration(
                labelText: '发件人',
                helperText: '用这个名字作为邮件发送人。',
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _senderAddress,
              decoration: const InputDecoration(
                labelText: '选择地址',
                helperText: '用这个邮件地址作为邮件发送人。',
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _replyAddress,
              decoration: const InputDecoration(
                labelText: '回复地址',
                helperText: '你希望回复的电子邮件地址，如果与发件人地址不同。',
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.md),
        _SectionCard(
          title: '发送测试邮件',
          children: [
            TextField(
              controller: _testContent,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '测试内容',
                helperText: '发送测试邮件时，您希望发送的内容。',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: RuQiSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () {},
                style: RuQiButtonStyles.secondary(context),
                child: const Text('发送测试邮件'),
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              style: RuQiButtonStyles.tertiary(context),
              child: const Text('清除'),
            ),
            const SizedBox(width: RuQiSpacing.sm),
            FilledButton(
              onPressed: () {},
              style: RuQiButtonStyles.primary(context),
              child: const Text('保存修改'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RadioLabel extends StatelessWidget {
  const _RadioLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
