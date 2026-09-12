import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/api/partner/models/partner_profile.dart';

void main() {
  test('PartnerProfile roundtrip', () {
    const profile = PartnerProfile(name: '华东渠道商', status: 'active');

    final json = profile.toJson();
    expect(json['name'], '华东渠道商');

    final parsed = PartnerProfile.fromJson(json);
    expect(parsed.status, 'active');
  });
}
