/// 地区 & 国家。
class RegionCountry {
  const RegionCountry({
    required this.zhName,
    required this.code2,
    required this.code3,
    required this.codeNum,
    required this.dialCode,
    required this.continent,
    this.localCode = '--',
    this.enabled = true,
  });

  final String zhName;
  final String code2;
  final String code3;
  final String codeNum;
  final String dialCode;
  final String continent;
  final String localCode;
  final bool enabled;
}

const regionCountries = [
  RegionCountry(zhName: '中国', code2: 'CN', code3: 'CHN', codeNum: '156', dialCode: '86', continent: 'AS1', localCode: 'zh-CN'),
  RegionCountry(zhName: '美国', code2: 'US', code3: 'USA', codeNum: '840', dialCode: '1', continent: 'AS4'),
  RegionCountry(zhName: '越南', code2: 'VN', code3: 'VNM', codeNum: '704', dialCode: '84', continent: 'AS1'),
  RegionCountry(zhName: '加纳', code2: 'GH', code3: 'GHA', codeNum: '288', dialCode: '233', continent: 'AS3'),
  RegionCountry(zhName: '法国', code2: 'FR', code3: 'FRA', codeNum: '250', dialCode: '33', continent: 'AS2'),
  RegionCountry(zhName: '俄罗斯', code2: 'RU', code3: 'RUS', codeNum: '643', dialCode: '7', continent: 'AS2', enabled: false),
];
