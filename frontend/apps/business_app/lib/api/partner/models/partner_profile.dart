import 'package:json_annotation/json_annotation.dart';

part 'partner_profile.g.dart';

@JsonSerializable()
class PartnerProfile {
  const PartnerProfile({
    required this.name,
    required this.status,
  });

  final String name;
  final String status;

  factory PartnerProfile.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerProfileToJson(this);
}
