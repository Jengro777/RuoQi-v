import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';

import 'verification_message_models.dart';

/// 打开验证消息设置面板（与内容区同尺寸）。
Future<void> showVerificationMessageSettingsDialog(
  BuildContext context,
  VerificationMessageItem item,
) {
  return showSystemSettingsPanel(
    context,
    title: '${item.name} 设置',
    child: VerificationMessageSettingsForm(item: item),
  );
}

/// 验证消息设置表单：主题、场景变量、电子邮件、发件人与短信渠道。
class VerificationMessageSettingsForm extends StatefulWidget {
  const VerificationMessageSettingsForm({super.key, required this.item});

  final VerificationMessageItem item;

  @override
  State<VerificationMessageSettingsForm> createState() =>
      _VerificationMessageSettingsFormState();
}

class _VerificationMessageSettingsFormState
    extends State<VerificationMessageSettingsForm> {
  late final TextEditingController _subject;
  late final TextEditingController _sender;
  late final TextEditingController _emailBody;
  late final TextEditingController _tencentTemplateId;
  late final TextEditingController _aliyunTemplateId;
  late final TextEditingController _smsBody;

  @override
  void initState() {
    super.initState();
    _subject = TextEditingController(text: widget.item.subject);
    _sender = TextEditingController(text: widget.item.sender);
    _emailBody = TextEditingController(text: widget.item.emailBody);
    _tencentTemplateId = TextEditingController(
      text: widget.item.sms?.tencentTemplateId ?? '',
    );
    _aliyunTemplateId = TextEditingController(
      text: widget.item.sms?.aliyunTemplateId ?? '',
    );
    _smsBody = TextEditingController(text: widget.item.sms?.smsBody ?? '');
  }

  @override
  void dispose() {
    _subject.dispose();
    _sender.dispose();
    _emailBody.dispose();
    _tencentTemplateId.dispose();
    _aliyunTemplateId.dispose();
    _smsBody.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _subject,
            decoration: InputDecoration(labelText: '主题', hintText: '邮件主题'),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '场景变量：${widget.item.sceneVariables.join('、')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          const _SectionLabel('电子邮件'),
          const SizedBox(height: RuQiSpacing.xs),
          TextField(
            controller: _emailBody,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '邮件正文模板',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          TextField(
            controller: _sender,
            decoration: const InputDecoration(labelText: '发件人'),
          ),
          if (widget.item.sms != null) ...[
            const SizedBox(height: RuQiSpacing.md),
            const _SectionLabel('短信'),
            const SizedBox(height: RuQiSpacing.xs),
            _ChannelField(
              label: '腾讯云短信',
              controller: _tencentTemplateId,
              fieldLabel: '模板 ID',
              helper:
                  '使用腾讯云短信，需要填写模板 ID；'
                  '若模板 ID 填写错误，无法保存提交短消息模板。'
                  '注意必须是腾讯审核通过的模板 ID，'
                  '短信内容以对应模板 ID 的短信内容为准。',
            ),
            const SizedBox(height: RuQiSpacing.md),
            _ChannelField(
              label: '阿里云短信',
              controller: _aliyunTemplateId,
              fieldLabel: '模板 ID',
              helper:
                  '使用阿里云短信，需要填写模板 ID；'
                  '若模板 ID 填写错误，无法保存提交短消息模板。'
                  '注意必须是阿里云审核通过的模板 ID，'
                  '短信内容以对应模板 ID 的短信内容为准。',
            ),
            const SizedBox(height: RuQiSpacing.md),
            _ChannelField(
              label: 'Arkesel',
              controller: _smsBody,
              fieldLabel: '短信内容',
              helper: 'Arkesel 短信，直接编写短信内容，不需要内容备案。',
              multiline: true,
            ),
          ],
          const SizedBox(height: RuQiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.tertiary(context),
                child: const Text('取消'),
              ),
              const SizedBox(width: RuQiSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.primary(context),
                child: const Text('保存修改'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ChannelField extends StatelessWidget {
  const _ChannelField({
    required this.label,
    required this.controller,
    required this.fieldLabel,
    required this.helper,
    this.multiline = false,
  });

  final String label;
  final TextEditingController controller;
  final String fieldLabel;
  final String helper;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        TextField(
          controller: controller,
          maxLines: multiline ? 4 : 1,
          decoration: InputDecoration(
            labelText: fieldLabel,
            helperText: helper,
            alignLabelWithHint: multiline,
          ),
        ),
      ],
    );
  }
}
