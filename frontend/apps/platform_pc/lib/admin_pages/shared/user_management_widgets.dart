import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

/// 用户板块共用小部件：页头、头像、状态徽章、分页脚。

/// 业务正文页头：标题 + 描述 + 右侧操作按钮。
class UserPageHeader extends StatelessWidget {
  const UserPageHeader({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: RuQiSpacing.md),
          FilledButton(
            onPressed: onAction,
            style: RuQiButtonStyles.primary(context),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}

/// 用户 / 角色 圆形缩写头像。
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.label, this.size = 36});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 已停用状态徽章（规范 §6.6 状态徽章）。
class UserStatusBadge extends StatelessWidget {
  const UserStatusBadge({super.key, required this.deactivated});

  final bool deactivated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    if (!deactivated) {
      return Text(
        '活跃',
        style: theme.textTheme.bodySmall?.copyWith(
          color: ext?.success ?? theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '已停用',
        style: theme.textTheme.bodySmall?.copyWith(
          color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 表格列头。
class UserColumnHeader extends StatelessWidget {
  const UserColumnHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 分页脚：页码 + 每页条数 + 总数（对应原型 1 2 3 ··· 10条/页 共N条 前往 页）。
class UserPagination extends StatelessWidget {
  const UserPagination({super.key, required this.total, this.pageSize = 10});

  final int total;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (final page in const ['1', '2', '3', '···'])
          Padding(
            padding: const EdgeInsets.only(right: RuQiSpacing.xxs),
            child: _PageButton(label: page, active: page == '1'),
          ),
        const Spacer(),
        Text(
          '$pageSize条/页 · 共$total条',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: RuQiSpacing.md),
        Text(
          '前往',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: RuQiSpacing.xs),
        SizedBox(
          width: 48,
          child: TextField(
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: RuQiSpacing.xs,
                vertical: 8,
              ),
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: RuQiSpacing.xs),
        Text(
          '页',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

/// 字段说明区块：标题 + 说明行。
typedef TipsSection = ({String title, List<String> items});

/// 小 tips 按钮：点击后在按钮旁弹出字段说明跟随面板（如 账号 字段说明）。
class UserTipsButton extends StatelessWidget {
  const UserTipsButton({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<TipsSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainerLow,
        ),
        elevation: WidgetStatePropertyAll(6),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) => InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: child,
      ),
      menuChildren: [
        SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final section in sections) ...[
                  const SizedBox(height: RuQiSpacing.sm),
                  Text(
                    section.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  for (final item in section.items)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '· $item',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
      child: Tooltip(
        message: '查看说明',
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.info_outline,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 表单类面板的底部操作行：取消 + 主操作（规范 §6.9）。
class UserFormActions extends StatelessWidget {
  const UserFormActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    this.onCancel,
    this.destructive = false,
  });

  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  /// 主操作为破坏性动作（如 停用）时使用 danger 按钮。
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RuQiSpacing.lg,
        RuQiSpacing.sm,
        RuQiSpacing.lg,
        RuQiSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: RuQiButtonStyles.tertiary(context),
            child: const Text('取消'),
          ),
          const SizedBox(width: RuQiSpacing.sm),
          if (destructive)
            FilledButton(
              onPressed: onConfirm,
              style: RuQiButtonStyles.danger(context),
              child: Text(confirmLabel),
            )
          else
            FilledButton(
              onPressed: onConfirm,
              style: RuQiButtonStyles.primary(context),
              child: Text(confirmLabel),
            ),
        ],
      ),
    );
  }
}
