//front_client\lib\auth\signup.dart
import 'package:flutter/material.dart';
import 'package:shared_carenest/auth/signup.dart' as SP;

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SP.SignupScreen(role: 'client');
  }
}
