import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart'; // Import the shared LoginScreen
import '../providers/user_provider.dart'; // Import the shared UserProvider
import '../widgets/loading_indicator.dart';
// Import the shared LoadingIndicator
// ... (imports stay the same)

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({Key? key, required this.role}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final Uri uri = Uri.parse('http://192.168.0.230:5000/api/auth/register');
      final Map<String, dynamic> body = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'fcm_token': fcmToken,
        'role': widget.role,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Backend registration response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                appName: 'Your App Name',
                tagline: 'Your App Tagline',
              ),
            ),
          );
        }
      } else {
        throw Exception("Ошибка регистрации: ${response.body}");
      }
    } catch (error) {
      print("Signup error: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('Регистрация',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                        labelText: 'ФИО', border: OutlineInputBorder()),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Введите ФИО' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Телефон', border: OutlineInputBorder()),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Введите номер телефона' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Введите email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Пароль', border: OutlineInputBorder()),
                    validator: (value) => (value?.length ?? 0) < 6
                        ? 'Минимум 6 символов'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _signUp(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Зарегистрироваться',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoginScreen(
                                  appName: 'Your App Name',
                                  tagline: 'Your App Tagline',
                                ))),
                    child: const Text('Уже есть аккаунт? Войти'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
