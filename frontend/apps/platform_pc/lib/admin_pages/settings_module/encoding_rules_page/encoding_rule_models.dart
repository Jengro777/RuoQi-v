/// 单号生成规则。
class EncodingRule {
  const EncodingRule({
    required this.name,
    required this.prefix,
    required this.rule,
    required this.note,
  });

  final String name;
  final String prefix;
  final String rule;
  final String note;
}

/// 单号规则列表（对应 设置-编码规则 原型）。
const encodingRules = [
  EncodingRule(
    name: '销售单号',
    prefix: 'SH',
    rule:
        '1.不重复\n2.纯数字\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(12～28位)',
    note: '--',
  ),
  EncodingRule(
    name: '售后单号',
    prefix: '--',
    rule:
        '1.不重复\n2.纯数字\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(12～16位)',
    note: 'eg：日期 + 自增长数字的售后单号',
  ),
  EncodingRule(
    name: '商品编号(ASIN)',
    prefix: '186',
    rule:
        '1.不重复\n2.数字、大写英文字母\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(10～13位)',
    note:
        '1 代表 C 端商城，86 代表中国站点。'
        '设备号15(取最后10位)+10位时间戳+序号(同一时间戳时自动排序，'
        '限制两位；超出两位数需要用户安全验证后重新生成)。',
  ),
  EncodingRule(
    name: 'FNSKU\n(Fulfillment Network Stock Keeping Unit)',
    prefix: '--',
    rule:
        '1.不重复\n2.数字、大写英文字母\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(8～13位)',
    note: '· 产品标签编码',
  ),
  EncodingRule(
    name: '货品箱码（箱唛号）',
    prefix: '--',
    rule:
        '1.不重复\n2.(大写英文字母 CTN) + 纯数字\n'
        '3.安全性（不能透露正式的运营信息）\n4.不能大规模使用随机码\n'
        '5.防止并发\n6.控制位数(10～18位)',
    note: 'eg：CTN20220202010305',
  ),
  EncodingRule(
    name: '批次号',
    prefix: 'BN',
    rule:
        '1.不重复\n2.(大写英文字母 BN) + 纯数字\n'
        '3.安全性（不能透露正式的运营信息）\n4.不能大规模使用随机码\n'
        '5.防止并发\n6.控制位数(10～18位)',
    note: '批次号：batch number\neg：BN20220202010305',
  ),
];
