import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/loading_indicator.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  final String appName;
  final String tagline;
  final Widget? signupScreen;

  const LoginScreen({
    Key? key,
    required this.appName,
    required this.tagline,
    this.signupScreen,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signIn(
          _emailController.text.trim(), _passwordController.text.trim());

      if (userProvider.isAuthenticated && mounted) {
      } else if (mounted &&
          userProvider.user == null &&
          !userProvider.isLoading) {
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ошибка входа.";
      if (e.code == 'user-not-found') {
        errorMessage = "Пользователь не найден.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Неверный пароль.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Ошибка входа: ${e.toString()}"),
              backgroundColor: Colors.red),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.tagline,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder()),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? 'Введите email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder()),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? 'Введите пароль' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _signIn(context),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Войти', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                if (widget.signupScreen != null)
                  TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => widget.signupScreen!)),
                      child: const Text('Создать аккаунт')),
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ForgotPassword())),
                    child: const Text('Забыли пароль?')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

