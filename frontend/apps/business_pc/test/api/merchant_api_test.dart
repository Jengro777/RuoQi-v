import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_pc/api/merchant/models/dashboard_summary.dart';

void main() {
  test('DashboardSummary roundtrip', () {
    const summary = DashboardSummary(
      merchantName: 'RuoQi 便利店',
      todayOrders: 12,
      todaySales: 3456.5,
    );

    final json = summary.toJson();
    expect(json['merchantName'], 'RuoQi 便利店');

    final parsed = DashboardSummary.fromJson(json);
    expect(parsed.todayOrders, 12);
    expect(parsed.todaySales, 3456.5);
  });
}
