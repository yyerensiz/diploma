//front_specialist\lib\auth\login.dart
import 'package:flutter/material.dart';
import 'package:shared_carenest/shared_package.dart' as SP; // Import shared package
import 'signup.dart'; // Import specialist-specific signup // Import specialist's user provider

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SP.LoginScreen(
      appName: 'CareNest Job',
      tagline: 'Платформа для специалистов',
      signupScreen: SignupScreen(), // Use specialist-specific signup
    );
  }
}