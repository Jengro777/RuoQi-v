import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'package:ruoqi_platform_pc/admin_pages/settings_module/auth_login_settings_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_module/email_settings_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_module/encoding_rules_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_module/general_settings_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_module/localization_settings_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/permissions_module/permission_management_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_module/sms_settings_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_module/verification_messages_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/users_module/roles_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/users_module/user_management_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/menus_module/menus_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/currency_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/import_regions_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/rate_history_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/region_country_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/tz_database_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/utc_timezone_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/basic_module/world_geo_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/localization_module/export_translations_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/localization_module/import_translations_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/localization_module/languages_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/localization_module/translations_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/login_logs_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/operation_logs_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/payment_logs_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/logs_module/verification_logs_page/index.dart';

/// 系统管理（系统全局管理）入口弹窗。
///
/// 按 DESIGN-consensus.md 规范实现：
/// - 顶部导航栏：surface 背景 + onSurface 文本、高 56、无阴影（§6.7）；
/// - 左侧菜单：surface + `outlineVariant` 描边，选中项 `primaryContainer` + 主色；
/// - 右侧内容区：按比例展示对应原型页面（裁掉原型自身的顶栏与侧栏，避免重复）。
///
/// 后续接入真实业务页面时，把 [_sections] 中每一项的 pageId 换成真实页面即可。
class SystemSettingsDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => const _SystemSettingsDialog(),
    );
  }
}

class _SidebarItem {
  const _SidebarItem(this.label, this.pageId);

  final String label;
  final String pageId;
}

class _SidebarSection {
  const _SidebarSection(this.label, this.items);

  final String label;
  final List<_SidebarItem> items;
}

/// 已优化为业务静态页的菜单项（原型 pageId → 正文组件）。
/// 未收录的菜单项仍回退到原型预览。
final _businessBodies = <String, WidgetBuilder>{
  'ja7Hc6Rku': (_) => const VerificationMessagesBody(),
  '1_d9YGUlp': (_) => const SmsSettingsBody(),
  'S6BHB6tQQ': (_) => const AuthLoginBody(),
  'Z0K3xYMgZ': (_) => const GeneralSettingsBody(),
  'EDryRTyjx': (_) => const LocalizationBody(),
  'j7jNSg7DW': (_) => const EmailSettingsBody(),
  'jOWxGolr4': (_) => const EncodingRulesBody(),
  'StMQ4cWti': (_) => const UsersBody(),
  'c50tDa7pFz': (_) => const PermissionsBody(),
  'XdvqIaB7_': (_) => const MenusBody(),
  'xZC4jWHWG': (_) => const WorldGeoBody(),
  'X0RCGzKUh': (_) => const RegionCountryBody(),
  '2SonlUXcm': (_) => const ImportRegionsBody(),
  'OJxsBTfEu': (_) => const UtcBody(),
  'aDfXovdwxK': (_) => const TzDatabaseBody(),
  'kFob4v_V6': (_) => const CurrencyBody(),
  'zvYxL_RQg': (_) => const RateHistoryBody(),
  'u7tmb4OBc': (_) => const LanguagesBody(),
  'UXGGZPuR9': (_) => const TranslationsBody(),
  'TpHbkdGMq': (_) => const ImportTranslationsBody(),
  'yq9YeBSKX': (_) => const ExportTranslationsBody(),
  'JSCSQH1Kc': (_) => const VerificationLogsBody(),
  'WkvHvCC8i': (_) => const OperationLogsBody(),
  'BYfUtX8cV': (_) => const LoginLogsBody(),
  'DwOYjtX0r': (_) => const PaymentLogsBody(),
};

/// 七个板块及其左侧菜单项，顺序与 管理后台 原型顶部导航一致。
/// 每个菜单项的裁切起点与展示尺寸由原型页面实际内容边界计算得到，
/// 避免固定偏移把页面元素裁掉。
const _sections = [
  _SidebarSection('设置', [
    _SidebarItem('通用', 'Z0K3xYMgZ'),
    _SidebarItem('本地化', 'EDryRTyjx'),
    _SidebarItem('电子邮件', 'j7jNSg7DW'),
    _SidebarItem('编码规则', 'jOWxGolr4'),
    _SidebarItem('短信', '1_d9YGUlp'),
    _SidebarItem('auth登录', 'S6BHB6tQQ'),
    _SidebarItem('验证消息', 'ja7Hc6Rku'),
  ]),
  _SidebarSection('用户', [
    _SidebarItem('用户', 'StMQ4cWti'),
    _SidebarItem('角色', 'c11sjQSJ1'),
  ]),
  _SidebarSection('权限', [
    _SidebarItem('权限', 'c50tDa7pFz'),
  ]),
  _SidebarSection('菜单', [
    _SidebarItem('菜单', 'XdvqIaB7_'),
  ]),
  _SidebarSection('基础', [
    _SidebarItem('世界地理规划', 'xZC4jWHWG'),
    _SidebarItem('地区&国家', 'X0RCGzKUh'),
    _SidebarItem('导入地区', '2SonlUXcm'),
    _SidebarItem('UTC', 'OJxsBTfEu'),
    _SidebarItem('时区数据库', 'aDfXovdwxK'),
    _SidebarItem('货币', 'kFob4v_V6'),
    _SidebarItem('历史汇率', 'zvYxL_RQg'),
  ]),
  _SidebarSection('语言', [
    _SidebarItem('多语言', 'u7tmb4OBc'),
    _SidebarItem('翻译', 'UXGGZPuR9'),
    _SidebarItem('导入', 'TpHbkdGMq'),
    _SidebarItem('导出', 'yq9YeBSKX'),
  ]),
  _SidebarSection('日志', [
    _SidebarItem('验证日志', 'JSCSQH1Kc'),
    _SidebarItem('操作日志', 'WkvHvCC8i'),
    _SidebarItem('登录日志', 'BYfUtX8cV'),
    _SidebarItem('支付日志', 'DwOYjtX0r'),
  ]),
];

/// 左侧菜单宽度，与 权限 页左侧面板一致。
const _leftMenuWidth = 300.0;

class _SystemSettingsDialog extends StatefulWidget {
  const _SystemSettingsDialog();

  @override
  State<_SystemSettingsDialog> createState() => _SystemSettingsDialogState();
}

class _SystemSettingsDialogState extends State<_SystemSettingsDialog> {
  int _sectionIndex = 0;
  int _itemIndex = 0;

  _SidebarSection get _section => _sections[_sectionIndex];

  void _selectSection(int index) {
    setState(() {
      _sectionIndex = index;
      _itemIndex = 0;
    });
  }

  void _selectItem(int index) {
    setState(() => _itemIndex = index);
  }

  /// 角色页「设置权限」跳转到权限板块（选中 权限 子项）。
  void _openPermissions() {
    setState(() {
      _sectionIndex = _sections.indexWhere((section) => section.label == '权限');
      _itemIndex = 0;
    });
  }

  Widget? _bodyFor(BuildContext context, _SidebarItem item) {
    if (item.pageId == 'c11sjQSJ1') {
      return RolesBody(onOpenPermissions: _openPermissions);
    }
    return _businessBodies[item.pageId]?.call(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = _section.items[_itemIndex];
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ConsoleTopBar(
            title: '管理后台',
            sectionIndex: _sectionIndex,
            onSectionSelected: _selectSection,
            onExit: () => Navigator.of(context).pop(),
            tabs: [for (final s in _sections) s.label],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 权限板块使用页面自身的角色左侧栏（原型中角色栏位于最左侧），
                // 隐藏通用左菜单，板块切换仍通过顶部导航。
                if (_section.label != '权限')
                  _LeftMenu(
                    section: _section,
                    selectedIndex: _itemIndex,
                    onSelected: _selectItem,
                  ),
                Expanded(
                  child: _PageContentView(
                    key: ValueKey(item.pageId),
                    body: _bodyFor(context, item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 左侧菜单：300px 宽、右侧描边，含搜索框；
/// 选中项 `primaryContainer` 底 + 主色文本（规范 §6.6/§1.2）。
class _LeftMenu extends StatefulWidget {
  const _LeftMenu({
    required this.section,
    required this.selectedIndex,
    required this.onSelected,
  });

  final _SidebarSection section;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<_LeftMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.section.items
        .where((item) => item.label.contains(_query))
        .toList();
    return Container(
      width: _leftMenuWidth,
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
            child: RuQiSearchField(
              hintText: '搜索菜单',
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('无匹配菜单', style: TextStyle(fontSize: 14)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final originalIndex = widget.section.items.indexOf(item);
                      final selected = originalIndex == widget.selectedIndex;
                      return InkWell(
                        onTap: () => widget.onSelected(originalIndex),
                        onHover: (_) {},
                        child: Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 40),
                          color: selected
                              ? theme.colorScheme.primaryContainer
                              : Colors.transparent,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: RuQiSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? theme.colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 内容区：展示业务页正文。
class _PageContentView extends StatelessWidget {
  const _PageContentView({
    super.key,
    this.body,
  });

  /// 业务页正文；
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    if (body != null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: body,
      );
    }
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(child: Text('页面开发中')),
    );
  }
}
