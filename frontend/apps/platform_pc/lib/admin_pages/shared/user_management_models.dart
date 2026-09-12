/// 用户板块业务数据模型（对应 管理后台-用户 原型）。
library;

/// 用户状态：活跃 / 已停用。
enum UserStatus { active, deactivated }

/// 控制台用户账号。
class UserAccount {
  const UserAccount({
    required this.name,
    required this.surname,
    required this.account,
    required this.email,
    required this.phone,
    required this.roles,
    required this.lastLogin,
    required this.status,
    this.isSelf = false,
  });

  final String name;
  final String surname;

  /// 登录账号，如 `admin : main`。
  final String account;
  final String email;
  final String phone;

  /// 所属角色组，如 `管理员`、`普通用户`。
  final List<String> roles;

  /// 最后一次登录时间描述，如 `2小时前`、`从未`。
  final String lastLogin;
  final UserStatus status;

  /// 当前登录者（Administrator / Me）。
  final bool isSelf;

  String get displayName => '$name $surname'.trim();

  UserAccount copyWith({List<String>? roles}) => UserAccount(
    name: name,
    surname: surname,
    account: account,
    email: email,
    phone: phone,
    roles: roles ?? this.roles,
    lastLogin: lastLogin,
    status: status,
    isSelf: isSelf,
  );
}

/// 角色组。
class RoleGroup {
  const RoleGroup({
    required this.name,
    required this.initial,
    required this.memberCount,
    required this.note,
    required this.isDefault,
  });

  final String name;

  /// 名称列展示的缩写，如 `管`。
  final String initial;
  final int memberCount;
  final String note;

  /// 管理员 / 所有用户 为特殊默认组，不可删除。
  final bool isDefault;
}

/// 用户列表（活跃 + 已停用，对应 用户(活跃) / 用户(已停用) 原型）。
const userAccounts = [
  UserAccount(
    name: 'Administrator',
    surname: 'Me',
    account: 'admin : main',
    email: 'm1@163.com',
    phone: '+233 2365456212',
    roles: ['管理员', '普通用户'],
    lastLogin: '2小时前',
    status: UserStatus.active,
    isSelf: true,
  ),
  UserAccount(
    name: 'account2',
    surname: 'sub',
    account: 'account2 : sub',
    email: 'm2@163.com',
    phone: '+86 15020579521',
    roles: ['普通用户'],
    lastLogin: '2小时前',
    status: UserStatus.active,
  ),
  UserAccount(
    name: 'Li',
    surname: 'L',
    account: 'li : main',
    email: 'm3@163.com',
    phone: '+233 236545622',
    roles: ['普通用户'],
    lastLogin: '5天前',
    status: UserStatus.active,
  ),
  UserAccount(
    name: 'Se',
    surname: 'S',
    account: 'se : main',
    email: 'm4@163.com',
    phone: '+233 236545623',
    roles: ['实施经理', '运营专员'],
    lastLogin: '3天前',
    status: UserStatus.active,
  ),
  UserAccount(
    name: 'Ni',
    surname: 'N',
    account: 'ni : main',
    email: 'm5@163.com',
    phone: '+233 236545624',
    roles: ['运营经理'],
    lastLogin: '从未',
    status: UserStatus.active,
  ),
  UserAccount(
    name: 'Ti',
    surname: 'T',
    account: 'ti : main',
    email: 'm6@163.com',
    phone: '+233 236545625',
    roles: ['实施专员'],
    lastLogin: '从未',
    status: UserStatus.deactivated,
  ),
];

/// 角色组列表（对应 角色 原型）。
const roleGroups = [
  RoleGroup(
    name: '管理员',
    initial: '管',
    memberCount: 100,
    note: '--',
    isDefault: true,
  ),
  RoleGroup(
    name: '所有用户',
    initial: '所',
    memberCount: 6,
    note: '默认包含全部用户',
    isDefault: true,
  ),
  RoleGroup(
    name: '实施经理',
    initial: '实',
    memberCount: 0,
    note: '--',
    isDefault: false,
  ),
  RoleGroup(
    name: '实施专员',
    initial: '实',
    memberCount: 0,
    note: '--',
    isDefault: false,
  ),
  RoleGroup(
    name: '运营经理',
    initial: '运',
    memberCount: 0,
    note: '--',
    isDefault: false,
  ),
  RoleGroup(
    name: '运营专员',
    initial: '运',
    memberCount: 0,
    note: '--',
    isDefault: false,
  ),
];

/// 权限模块（对应 权限 原型的 一级菜单 / 二级菜单）。
const permissionModules = [
  ('订单', ['销售订单', '售后订单', '发货单']),
  ('商品', ['商品列表', '商品分类', '品牌']),
  ('财务', ['收款记录', '退款记录', '发票']),
  ('运营', ['活动管理', '优惠券', '公告']),
  ('用户管理', ['用户列表', '角色']),
  ('系统管理', ['设置', '菜单']),
  ('系统日志', ['操作日志', '登录日志']),
  ('系统监控', ['在线用户', '服务监控']),
];
