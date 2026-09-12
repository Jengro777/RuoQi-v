/// 历史汇率。
class RateHistory {
  const RateHistory({
    required this.type,
    required this.from,
    required this.to,
    required this.originalRate,
    required this.rateFloat,
    required this.siteRate,
    required this.effectiveAt,
    required this.expireAt,
    required this.account,
    required this.createdAt,
    this.enabled = true,
  });

  final String type;
  final String from;
  final String to;
  final String originalRate;
  final String rateFloat;
  final String siteRate;
  final String effectiveAt;
  final String expireAt;
  final String account;
  final String createdAt;
  final bool enabled;
}

const rateHistories = [
  RateHistory(type: '固定汇率', from: 'USD', to: 'CNY', originalRate: '0.900220', rateFloat: '+0.00020', siteRate: '0.900222', effectiveAt: '2022/02/02 02:02:03', expireAt: '2022/03/02 02:02:03', account: 'account1', createdAt: '2022/02/02 02:02:03'),
  RateHistory(type: '实时汇率(Xe)', from: 'USD', to: 'GHS', originalRate: '8.200000', rateFloat: '+0.23156', siteRate: '8.362565', effectiveAt: '2022/02/02 02:02:03', expireAt: '--', account: 'account2', createdAt: '2022/02/02 02:02:03'),
  RateHistory(type: '固定汇率', from: 'USD', to: 'VND', originalRate: '23650.00', rateFloat: '-0.321563', siteRate: '23620.00', effectiveAt: '2021/12/01 00:00:00', expireAt: '2022/01/01 00:00:00', account: 'account2', createdAt: '2021/11/30 10:00:00', enabled: false),
];
