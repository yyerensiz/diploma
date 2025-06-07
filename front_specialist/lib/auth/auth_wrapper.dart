//front_specialist\lib\auth\auth_wrapper.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_carenest/shared_package.dart'; 
import '../screens/navbar.dart'; 

class SpecialistAuthWrapper extends StatelessWidget { 
  const SpecialistAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      expectedRole: 'specialist',
      mainScreen: MainScreen(),
      unauthorizedMessage: 'unauthorized_role'.tr(),
      appName: 'app_title'.tr(),
      tagline: 'tagline'.tr(),
    );
  }
}