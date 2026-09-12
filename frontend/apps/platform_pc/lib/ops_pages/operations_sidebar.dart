// 运营后台左侧菜单面板（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 左侧菜单为两级树形导航：一级为板块（租户 / 团队空间 / 项目 /
// API授权 / 个人中心），二级为主页面（真实业务页）。
import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'operations_nav.dart';

/// 树形菜单节点：一级为板块组（item 为 null），其余对应真实业务页。
class _TreeNode {
  const _TreeNode(this.title, this.item, this.children, this.path);

  final String title;
  final OperationsNavItem? item;
  final List<_TreeNode> children;

  /// 节点路径前缀，用于展开状态跟踪。
  final String path;
}

/// 全量菜单树：一级为板块组，二级为主页面（均为叶子节点）。
List<_TreeNode> _buildFullTree() {
  return [
    for (final s in operationsNavSections)
      _TreeNode(s.label, null, [
        for (final item in s.items)
          _TreeNode(item.label, item, const [], s.label),
      ], s.label),
  ];
}

/// 搜索过滤：节点自身或任意子孙命中时保留，命中子树的祖先一并保留。
List<_TreeNode> _filterTree(List<_TreeNode> nodes, String query) {
  if (query.isEmpty) {
    return nodes;
  }
  return [
    for (final n in nodes)
      if (n.title.contains(query) ||
          n.children.any((c) => _filterTree([c], query).isNotEmpty))
        _TreeNode(n.title, n.item, _filterTree(n.children, query), n.path),
  ];
}

class OperationsSidebar extends StatefulWidget {
  const OperationsSidebar({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  /// 当前选中的页面标题（用于高亮）。
  final String? selectedId;

  /// 点击菜单项时回调（由弹窗在右侧内容区展示对应页面）。
  final ValueChanged<OperationsNavItem> onSelected;

  @override
  State<OperationsSidebar> createState() => _OperationsSidebarState();
}

class _OperationsSidebarState extends State<OperationsSidebar> {
  String _query = '';

  /// 用户折叠的节点路径；板块组默认只展开包含当前选中页的那一个。
  final Set<String> _collapsed = {};

  String get _selectedSection {
    final id = widget.selectedId;
    if (id == null) {
      return '';
    }
    for (final s in operationsNavSections) {
      if (s.items.any((item) => item.label == id)) {
        return s.label;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roots = _filterTree(_buildFullTree(), _query);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RuQiSpacing.lg,
              RuQiSpacing.md,
              RuQiSpacing.lg,
              RuQiSpacing.sm,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
              decoration: const InputDecoration(
                hintText: '搜索菜单',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.xs,
                  vertical: 10,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: roots.isEmpty
                ? const Center(
                    child: Text('无匹配菜单', style: TextStyle(fontSize: 14)),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final node in roots) ..._buildRows(node, 0),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows(_TreeNode node, int depth) {
    final theme = Theme.of(context);
    final hasChildren = node.children.isNotEmpty;
    // 搜索时强制展开，方便查看命中项。
    final expanded = _isExpanded(node);
    final isSection = node.item == null && hasChildren;
    final selected = node.item?.label == widget.selectedId;
    return [
      InkWell(
        onTap: () => _onNodeTap(node, expanded, isSection),
        child: Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 12.0 + depth * 20),
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: hasChildren
                    ? Icon(
                        expanded ? Icons.expand_more : Icons.chevron_right,
                        size: 16,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  node.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSection || selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (hasChildren && expanded)
        for (final child in node.children) ..._buildRows(child, depth + 1),
    ];
  }

  bool _isExpanded(_TreeNode node) {
    if (_query.isNotEmpty) {
      return true;
    }
    if (_collapsed.contains(node.path)) {
      return false;
    }
    // 板块组默认只展开包含当前选中页的那一个。
    final isSection = node.item == null && node.children.isNotEmpty;
    if (isSection) {
      return node.path == _selectedSection;
    }
    return true;
  }

  void _onNodeTap(_TreeNode node, bool expanded, bool isSection) {
    final item = node.item;
    if (item != null) {
      widget.onSelected(item);
    }
    if (node.children.isEmpty) {
      return;
    }
    setState(() {
      if (expanded) {
        _collapsed.add(node.path);
      } else {
        _collapsed.remove(node.path);
        // 展开板块组时顺带打开其第一个页面。
        if (isSection) {
          final first = node.children.firstWhere(
            (c) => c.item != null,
            orElse: () => node.children.first,
          );
          if (first.item != null) {
            widget.onSelected(first.item!);
          }
        }
      }
    });
  }
}
