//front_specialist\lib\auth\auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:shared_carenest/shared_package.dart'; //  Import the shared package
import '../screens/navbar.dart'; //  Import the app's MainScreen
//import '../providers/user_provider.dart'; //  Import the app's UserProvider

class SpecialistAuthWrapper extends StatelessWidget { //  Rename to be more specific
  const SpecialistAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      expectedRole: 'specialist',
      mainScreen: MainScreen(), //  Use the specialist app's MainScreen
      unauthorizedMessage: "Недопустимая роль: только специалисты могут войти в это приложение.",
      appName: 'CareNest Job', // Provide appName here
      tagline: 'Помощь родителям',
    );
  }
}