import 'package:json_annotation/json_annotation.dart';

part 'system_info.g.dart';

@JsonSerializable()
class SystemInfo {
  const SystemInfo({
    required this.name,
    required this.version,
    required this.status,
  });

  final String name;
  final String version;
  final String status;

  factory SystemInfo.fromJson(Map<String, dynamic> json) =>
      _$SystemInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SystemInfoToJson(this);
}
