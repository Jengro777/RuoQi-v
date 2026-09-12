// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemInfo _$SystemInfoFromJson(Map<String, dynamic> json) => SystemInfo(
  name: json['name'] as String,
  version: json['version'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$SystemInfoToJson(SystemInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'status': instance.status,
    };
