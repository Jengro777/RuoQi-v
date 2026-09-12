import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/merchant/business/account_frozen_dialog.dart';
import 'package:ruoqi_business_app/merchant/business/account_links_page.dart';
import 'package:ruoqi_business_app/merchant/business/account_log_page.dart';
import 'package:ruoqi_business_app/merchant/business/account_security_page.dart';
import 'package:ruoqi_business_app/merchant/business/agreement_dialog.dart';
import 'package:ruoqi_business_app/merchant/business/device_list_page.dart';
import 'package:ruoqi_business_app/merchant/business/edit_profile_page.dart';
import 'package:ruoqi_business_app/merchant/business/forgot_password_page.dart';
import 'package:ruoqi_business_app/merchant/business/login_methods_page.dart';
import 'package:ruoqi_business_app/merchant/business/phone_not_registered_dialog.dart';
import 'package:ruoqi_business_app/merchant/business/profile_page.dart';
import 'package:ruoqi_business_app/merchant/business/register_page.dart';
import 'package:ruoqi_business_app/merchant/business/set_password_page.dart';
import 'package:ruoqi_business_app/merchant/business/sms_login_page.dart';
import 'package:ruoqi_business_app/merchant/business/third_party_login_page.dart';

void main() {
  testWidgets('merchant business pages render without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    final pages = <Widget>[
      const LoginMethodsPage(),
      const SmsLoginPage(),
      const ProfilePage(),
      const AccountSecurityPage(),
      const RegisterPage(),
      const SetPasswordPage(),
      const ForgotPasswordPage(),
      const EditProfilePage(),
      const AccountLinksPage(),
      const DeviceListPage(),
      const AccountLogPage(),
      const ThirdPartyLoginPage(),
    ];
    for (final page in pages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$page should render');
    }
    for (final dialog in <Widget>[
      const AccountFrozenDialog(),
      const PhoneNotRegisteredDialog(),
      const AgreementDialog(),
    ]) {
      await tester.pumpWidget(MaterialApp(home: dialog));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$dialog should render');
    }
    tester.view.reset();
  });
}
