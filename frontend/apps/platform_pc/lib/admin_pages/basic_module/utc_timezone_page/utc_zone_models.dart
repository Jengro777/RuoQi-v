/// UTC 时区行。
typedef UtcZoneRow = ({String id, String label, String center, String range});

String _meridian(int offset) {
  if (offset == 0) return '0°';
  if (offset.abs() == 12) return '180°';
  return offset > 0 ? '${offset * 15}°E' : '${-offset * 15}°W';
}

String _range(int offset) {
  if (offset.abs() == 12) return '172.5°E~172.5°W';
  String fmt(double v) {
    final label = v < 0 ? 'W' : 'E';
    final s = v.abs().toStringAsFixed(1).replaceAll('.0', '');
    return '$s°$label';
  }
  final low = offset * 15 - 7.5;
  final high = offset * 15 + 7.5;
  return '${fmt(low)}~${fmt(high)}';
}

final utcZoneRows = <UtcZoneRow>[
  for (var i = 0; i < 24; i++)
    if (i == 0)
      (id: '0', label: 'UTC Z', center: '0°', range: '7.5°W~7.5°E')
    else if (i <= 11)
      (
        id: '$i',
        label: 'UTC +$i',
        center: _meridian(i),
        range: _range(i),
      )
    else if (i == 12)
      (id: '12', label: 'UTC ±12', center: '180°', range: '172.5°E~172.5°W')
    else
      (
        id: '$i',
        label: 'UTC ${i - 24}',
        center: _meridian(i - 24),
        range: _range(i - 24),
      ),
];
