import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 设置-通用 业务正文（替换静态原型复刻页）。
class GeneralSettingsBody extends StatefulWidget {
  const GeneralSettingsBody({super.key});

  @override
  State<GeneralSettingsBody> createState() => _GeneralSettingsBodyState();
}

class _GeneralSettingsBodyState extends State<GeneralSettingsBody> {
  final _siteName = TextEditingController(text: 'Site Name');
  final _siteUrl = TextEditingController(text: 'https://domain.com');
  final _helpEmail = TextEditingController(text: 'email@yourcompany.com');
  final _copyright = TextEditingController(text: 'Copuright@2021-2100 公司名称');
  final _icp = TextEditingController(text: '*ICP证******号');
  final _icpRecordUrl = TextEditingController();
  final _beianLink = TextEditingController(text: 'http://beian.miit.gov.vn');

  @override
  void dispose() {
    _siteName.dispose();
    _siteUrl.dispose();
    _helpEmail.dispose();
    _copyright.dispose();
    _icp.dispose();
    _icpRecordUrl.dispose();
    _beianLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        _Header(title: '通用', description: '实例的基础信息与备案信息。'),
        const SizedBox(height: RuQiSpacing.lg),
        _SectionCard(
          title: '基础信息',
          children: [
            TextField(
              controller: _siteName,
              decoration: const InputDecoration(
                labelText: '站点名称',
                helperText: '用于该实例的名称。',
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _siteUrl,
              decoration: const InputDecoration(
                labelText: '网站URL',
                helperText:
                    '该 URL 用于在电子邮件中创建链接与认证重定向，'
                    '修改可能破坏功能或导致无法登录。',
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _helpEmail,
              decoration: const InputDecoration(
                labelText: '帮助请求的电子邮件地址',
                helperText: '如果用户遇到问题，应该参考的电子邮件地址。',
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.md),
        _SectionCard(
          title: '备案信息',
          children: [
            Text(
              'Favorites Icon',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: RuQiSpacing.xs),
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '格式：svg、png、jpeg　尺寸：32 × 32 px',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RuQiSpacing.xs),
            Text(
              '收藏夹图标，亦被称为 website icon（网页图标）、'
              'page icon（页面图标）或 urlicon（URL 图标）。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _copyright,
              decoration: const InputDecoration(labelText: '版权信息'),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _icp,
              decoration: const InputDecoration(labelText: 'ICP备案号'),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _icpRecordUrl,
              decoration: const InputDecoration(labelText: '联网备案地址'),
            ),
            const SizedBox(height: RuQiSpacing.md),
            TextField(
              controller: _beianLink,
              decoration: const InputDecoration(labelText: '域名信息备案系统链接'),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {},
            style: RuQiButtonStyles.primary(context),
            child: const Text('保存修改'),
          ),
        ),
      ],
    );
  }
}

/// 业务页头部：标题 + 说明。
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

/// 表单分区卡片。
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
