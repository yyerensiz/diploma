//front_specialist\lib\auth\signup.dart
import 'package:flutter/material.dart';
import 'package:shared_carenest/auth/signup.dart' as SP; 

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SP.SignupScreen(role: 'specialist');
  }
}