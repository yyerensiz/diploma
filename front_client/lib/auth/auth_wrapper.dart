//front_client\lib\auth\auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_carenest/shared_package.dart';
import '../screens/common/navbar.dart';

class ClientAuthWrapper extends StatelessWidget {
  const ClientAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      expectedRole: 'client',
      mainScreen: const MainScreen(),
      unauthorizedMessage: 'unauthorized_role'.tr(),
      appName: 'app_title'.tr(),
      tagline: 'tagline'.tr(),
    );
  }
}
