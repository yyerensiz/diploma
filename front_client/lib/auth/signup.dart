import 'package:flutter/material.dart';
import 'package:shared_carenest/auth/signup.dart' as SP; // Import the shared SignupScreen

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SP.SignupScreen(role: 'client'); // Or 'specialist'
  }
}