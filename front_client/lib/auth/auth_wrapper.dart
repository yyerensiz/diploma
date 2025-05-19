import 'package:flutter/material.dart';
import 'package:shared_carenest/shared_package.dart'; // Import the shared package
import '../screens/common/navbar.dart'; // Import the app's MainScreen
// import '../providers/user_provider.dart'; // Import the app's UserProvider

class ClientAuthWrapper extends StatelessWidget {
  const ClientAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      expectedRole: 'client',
      mainScreen: MainScreen(),
      unauthorizedMessage:
          "Недопустимая роль: только клиенты могут войти в это приложение.",
      appName: 'CareNest', // Provide appName here
      tagline: 'Помощь родителям', // Provide tagline here
    );
  }
}
