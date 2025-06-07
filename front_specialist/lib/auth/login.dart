//front_specialist\lib\auth\login.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_carenest/shared_package.dart' as SP; 
import 'signup.dart'; 

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.translate),
          onPressed: () {
            final locales = context.supportedLocales;
            final current = context.locale;
            final next = locales[(locales.indexOf(current) + 1) % locales.length];
            context.setLocale(next);
          },
        ),
        title: Text('app_title'.tr()),
        centerTitle: true,
      ),
      body: SP.LoginScreen(
        appName: 'app_title'.tr(),
        tagline: 'tagline'.tr(),
        signupScreen: SignupScreen(),
      ),
    );
  }
}