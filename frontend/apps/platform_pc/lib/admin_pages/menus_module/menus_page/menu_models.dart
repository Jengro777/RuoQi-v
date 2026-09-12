/// 菜单项：顶菜单 / 左菜单 / 按钮。
class MenuItem {
  const MenuItem({
    required this.name,
    required this.type,
    required this.parent,
    required this.sort,
    this.icon = '',
    this.componentPath = '',
    this.permissionKey = '',
    this.url = '',
  });

  final String name;
  final String type;
  final String parent;
  final String icon;
  final String componentPath;
  final String permissionKey;
  final String url;
  final int sort;
}

const menuItems = [
  MenuItem(name: '设置', type: '顶菜单', parent: '根目录', sort: 1, icon: 'setting', componentPath: '/settings'),
  MenuItem(name: '用户', type: '顶菜单', parent: '根目录', sort: 2, icon: 'user', componentPath: '/users'),
  MenuItem(name: '权限', type: '顶菜单', parent: '根目录', sort: 3, icon: 'shield', componentPath: '/permissions'),
  MenuItem(name: '菜单', type: '顶菜单', parent: '根目录', sort: 4, icon: 'menu', componentPath: '/menus'),
  MenuItem(name: '基础', type: '顶菜单', parent: '根目录', sort: 5, icon: 'base', componentPath: '/base'),
  MenuItem(name: '语言', type: '顶菜单', parent: '根目录', sort: 6, icon: 'language', componentPath: '/lang'),
  MenuItem(name: '日志', type: '顶菜单', parent: '根目录', sort: 7, icon: 'log', componentPath: '/logs'),
  MenuItem(name: '时区', type: '左菜单', parent: '基础', sort: 1, icon: 'timezone', componentPath: '/base/timezone', permissionKey: 'base:timezone'),
  MenuItem(name: '货币', type: '左菜单', parent: '基础', sort: 2, icon: 'currency', componentPath: '/base/currency', permissionKey: 'base:currency'),
  MenuItem(name: '历史汇率', type: '左菜单', parent: '基础', sort: 3, icon: 'rate', componentPath: '/base/rate', permissionKey: 'base:rate'),
  MenuItem(name: '多语言', type: '左菜单', parent: '语言', sort: 1, icon: 'language', componentPath: '/lang/multi', permissionKey: 'lang:multi'),
  MenuItem(name: '翻译', type: '左菜单', parent: '语言', sort: 2, icon: 'translate', componentPath: '/lang/translate', permissionKey: 'lang:translate'),
  MenuItem(name: '导入', type: '左菜单', parent: '语言', sort: 3, icon: 'import', componentPath: '/lang/import', permissionKey: 'lang:import'),
  MenuItem(name: '导出', type: '左菜单', parent: '语言', sort: 4, icon: 'export', componentPath: '/lang/export', permissionKey: 'lang:export'),
  MenuItem(name: '验证日志', type: '左菜单', parent: '日志', sort: 1, icon: 'log', componentPath: '/logs/verify', permissionKey: 'logs:verify'),
  MenuItem(name: '操作日志', type: '左菜单', parent: '日志', sort: 2, icon: 'log', componentPath: '/logs/operate', permissionKey: 'logs:operate'),
  MenuItem(name: '登录日志', type: '左菜单', parent: '日志', sort: 3, icon: 'log', componentPath: '/logs/login', permissionKey: 'logs:login'),
  MenuItem(name: '支付日志', type: '左菜单', parent: '日志', sort: 4, icon: 'log', componentPath: '/logs/pay', permissionKey: 'logs:pay'),
];
