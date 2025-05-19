import 'package:flutter/material.dart';
import 'package:shared_carenest/auth/login.dart' as SP;  // Import shared package
import 'signup.dart'; // Import client-specific signup // Import client's user provider

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SP.LoginScreen(
      appName: 'CareNest',
      tagline: 'Помощь родителям',
      signupScreen: SignupScreen(), // Use client-specific signup
    );
  }
}