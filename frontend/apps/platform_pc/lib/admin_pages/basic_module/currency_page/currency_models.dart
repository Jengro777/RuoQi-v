/// 货币。
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.zhName,
    required this.enName,
    required this.decimals,
    required this.rateFloat,
    required this.siteRate,
    required this.liveRate,
    this.isBase = false,
    this.enabled = true,
  });

  final String code;
  final String symbol;
  final String zhName;
  final String enName;
  final int decimals;
  final String rateFloat;
  final String siteRate;
  final String liveRate;
  final bool isBase;
  final bool enabled;
}

const currencies = [
  Currency(code: 'USD', symbol: r'$', zhName: '美元', enName: 'dollar', decimals: 2, rateFloat: '+0.00020', siteRate: '0.900220', liveRate: '0.900222(xe)'),
  Currency(code: 'CNY', symbol: '¥', zhName: '人民币', enName: 'Chinese Yuan', decimals: 2, rateFloat: '+0.000360', siteRate: '0.820000', liveRate: '0.820000(xe)', isBase: true),
  Currency(code: 'ETB', symbol: 'Br', zhName: '比尔', enName: 'Birr', decimals: 2, rateFloat: '-0.000120', siteRate: '0.063565', liveRate: '0.063565(xe)'),
  Currency(code: 'GHS', symbol: '₵', zhName: '塞地', enName: 'Cedi', decimals: 2, rateFloat: '+0.231560', siteRate: '0.362565', liveRate: '0.362565(xe)'),
  Currency(code: 'VND', symbol: '₫', zhName: '越南盾', enName: 'Vietnamese Dong', decimals: 0, rateFloat: '-0.321563', siteRate: '1.000000', liveRate: '1.000000(xe)', enabled: false),
];
