// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    DashboardSummary(
      merchantName: json['merchantName'] as String,
      todayOrders: (json['todayOrders'] as num).toInt(),
      todaySales: (json['todaySales'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardSummaryToJson(DashboardSummary instance) =>
    <String, dynamic>{
      'merchantName': instance.merchantName,
      'todayOrders': instance.todayOrders,
      'todaySales': instance.todaySales,
    };
