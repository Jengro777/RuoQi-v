/// 大洲 / 大洋板块。
class GeoPlate {
  const GeoPlate({
    required this.code,
    required this.zhName,
    required this.enName,
  });

  final String code;
  final String zhName;
  final String enName;
}

const geoPlates = [
  GeoPlate(code: 'AS1', zhName: '亚洲', enName: 'Asia'),
  GeoPlate(code: 'AS2', zhName: '欧洲', enName: 'Europe'),
  GeoPlate(code: 'AS3', zhName: '非洲', enName: 'Africa'),
  GeoPlate(code: 'AS4', zhName: '北美洲', enName: 'North America'),
  GeoPlate(code: 'AS5', zhName: '南美洲', enName: 'South America'),
  GeoPlate(code: 'AS6', zhName: '南极洲', enName: 'Antarctica'),
  GeoPlate(code: 'AS7', zhName: '大洋洲', enName: 'Oceania'),
  GeoPlate(code: 'BS1', zhName: '太平洋', enName: 'Pacific Ocean'),
  GeoPlate(code: 'BS2', zhName: '大西洋', enName: 'Atlantic Ocean'),
  GeoPlate(code: 'BS3', zhName: '印度洋', enName: 'Indian Ocean'),
  GeoPlate(code: 'BS4', zhName: '北冰洋', enName: 'Arctic Ocean'),
];
