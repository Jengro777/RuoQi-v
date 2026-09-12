/// 时区数据库条目。
class TzDatabaseEntry {
  const TzDatabaseEntry({
    required this.id,
    required this.zoneId,
    required this.offset,
    required this.dst,
    required this.city,
  });

  final String id;
  final String zoneId;
  final String offset;
  final String dst;
  final String city;
}

const tzDatabaseEntries = [
  TzDatabaseEntry(
    id: '1',
    zoneId: 'Europe/London',
    offset: 'UTC +0:00',
    dst: '无',
    city: '伦敦',
  ),
  TzDatabaseEntry(
    id: '2',
    zoneId: 'Asia/Shanghai',
    offset: 'UTC +8:00',
    dst: '无',
    city: '北京 / 上海',
  ),
  TzDatabaseEntry(
    id: '3',
    zoneId: 'America/New_York',
    offset: 'UTC -5:00',
    dst: '每年的07月的第N个周日的 24:00起 ~ 每年的10月的第三个周日的24:00止',
    city: '纽约',
  ),
  TzDatabaseEntry(
    id: '4',
    zoneId: 'Europe/Berlin',
    offset: 'UTC +1:00',
    dst: '夏令时',
    city: '柏林',
  ),
];
