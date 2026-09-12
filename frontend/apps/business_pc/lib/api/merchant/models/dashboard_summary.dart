import 'package:json_annotation/json_annotation.dart';

part 'dashboard_summary.g.dart';

@JsonSerializable()
class DashboardSummary {
  const DashboardSummary({
    required this.merchantName,
    required this.todayOrders,
    required this.todaySales,
  });

  final String merchantName;
  final int todayOrders;
  final double todaySales;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardSummaryToJson(this);
}
